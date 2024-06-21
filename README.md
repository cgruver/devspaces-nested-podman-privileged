### Run a container:

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
