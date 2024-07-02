# Enabling `podman run` in OpenShift Dev Spaces with a Rootless Privileged Workspace

__Note:__ It is recommended that this configuration only be used on an OpenShift cluster that is accessible by very trusted users.  Because the workspace is allowed to run privileged non-root containers, there is risk of breakout into the underlying compute node.

I would recommend that this configuration be deployed to a cluster that is dedicated to developer use, and only accessible by a trusted group of developers.

## Allow privileged rootless pods in Dev Spaces

### Create the following SCC as a cluster-admin

__Note:__ This differs from the default `container-build` SCC which is bundled with Dev Spaces by adding the entry: `allowPrivilegedContainer: true`

The containers in a workspace will still run as a random non-root UID.  However, they will be capable of running as privileged which allows them to run in an unconstrained `selinux` context, and gives the container an unmasked root filesystem. 

```bash
cat << EOF | oc apply -f -
apiVersion: security.openshift.io/v1
metadata:
  name: nested-podman-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: true
allowedCapabilities:
- SETUID
- SETGID
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
groups: []
kind: SecurityContextConstraints
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
runAsUser:
  type: MustRunAsRange
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
EOF
```

### Modify the CheCluster CR to use the new SCC

__Note:__ If you already have a `CheCluster` CR created, then you can just modify it.

__Caution:__ You will likely have to delete and recreate any existing workspaces

Change the entry for `containerBuildConfiguration` to look like:

```bash
containerBuildConfiguration:
  openShiftSecurityContextConstraint: nested-podman-scc
```

__Example of a new install:__

```bash
cat << EOF | oc apply -f -
apiVersion: v1                      
kind: Namespace                 
metadata:
  name: devspaces
---           
apiVersion: org.eclipse.che/v2 
kind: CheCluster   
metadata:              
  name: devspaces  
  namespace: devspaces
spec:                         
  components:                  
    cheServer:      
      debug: false
      logLevel: INFO
    metrics:                
      enable: true
    pluginRegistry:
      openVSXURL: https://open-vsx.org
  containerRegistry: {}      
  devEnvironments:       
    startTimeoutSeconds: 300
    secondsOfRunBeforeIdling: -1
    maxNumberOfWorkspacesPerUser: -1
    maxNumberOfRunningWorkspacesPerUser: 5
    containerBuildConfiguration:
      openShiftSecurityContextConstraint: nested-podman-scc
    disableContainerBuildCapabilities: false
    defaultComponents:
    - name: dev-tools
      container:
        image: quay.io/cgruver0/che/dev-tools:latest
        memoryLimit: 6Gi
        mountSources: true
    defaultEditor: che-incubator/che-code/latest
    defaultNamespace:
      autoProvision: true
      template: <username>-devspaces
    secondsOfInactivityBeforeIdling: 1800
    storage:
      pvcStrategy: per-workspace
  gitServices: {}
  networking: {}  
EOF
```

### Create a Workspace to use a `privileged` container

Example `devfile.yaml`

```yaml
schemaVersion: 2.2.0
attributes:
  controller.devfile.io/storage-type: per-workspace
metadata:
  name: che-nested-containers-test
components:
- name: dev-tools
  attributes:
    container-overrides: 
      securityContext:
        privileged: true
  container: 
    image: quay.io/cgruver0/che/nested:latest
    memoryLimit: 6Gi
    mountSources: true
    env:
    - name: SHELL
      value: "/bin/zsh"
    - name: DOCKER_CMD
      value: podman
- volume:
    size: 10Gi
  name: projects
```

## Demos for Nested Podman

### Run a container in the workspace:

1. Open a terminal into the `openshift-nested-containers` project.

1. Clear the `CONTAINER_HOST` environment variable: (We're going to run this without a "remote" podman socket)

   ```bash
   unset CONTAINER_HOST
   ```

1. Run the following:

   ```bash
   podman run -d --rm --name webserver -p 8080:80 quay.io/libpod/banner
   curl http://localhost:8080
   ```

1. Run an interactive container:

   ```bash
   podman run -it --rm registry.access.redhat.com/ubi9/ubi-minimal
   ```

### Demo of Ansible Navigator

1. Clear the `CONTAINER_HOST` environment variable: (We're going to run this without a "remote" podman socket)

   ```bash
   unset CONTAINER_HOST
   ```

1. Open a terminal into the `ansible-demo` project.

1. Run the following command:

   ```bash
   ansible-navigator run helloworld.yaml
   ```

### Demo of AWS SAM CLI with Podman

1. Use the `Task Manager` extension to run the `Start Podman Service` task.

1. Open a terminal in the `sam-cli-demo` project:

   ```bash
   sam init --name sam-py-app --architecture=x86_64 --location="./python3.9/hello" --no-tracing --no-application-insights --no-input
   cd sam-py-app
   sam build
   sam local start-api --debug --docker-network=podman
   ```

1. Open a second terminal to invoke the Lambda function:

   ```bash
   curl http://127.0.0.1:3000/hello
   ```

### Demo of Quarkus Dev Services with Podman

1. Open a terminal in the `quarkus-dev-services-demo` project:

   ```bash
   mvn clean
   mvn test
   ```

## Demo of AWS Dev With Localstack with Podman

1. Use the `Task Manager` extension to run the `Start Localstack Service` task.

1. Open a terminal in the `localstack-demo` project:

   ```bash
   make deploy
   awslocal s3 ls s3://archive-bucket/
   ```
