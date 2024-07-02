
# This is a Dockerfile for the dev-tools/dev-workspace-nested:ubi9 image.


## START target image dev-tools/dev-workspace-nested:ubi9
## \
FROM registry.access.redhat.com/ubi9-minimal


USER root

###### START module 'base:v1.0'
###### \
    # Copy 'base' module general artifacts to '/tmp/artifacts/' destination
    COPY \
        entrypoint.sh \
        entrypoint-nested.sh \
        entrypoint-userns.sh \
        /tmp/artifacts/
    # Copy 'base' module content
    COPY modules/base /tmp/scripts/base
    # Switch to 'root' user for package management for 'base' module defined packages
    USER root
    # Install packages defined in the 'base' module
    RUN microdnf --disableplugin=subscription-manager --setopt=tsflags=nodocs --setopt=install_weak_deps=0 install -y procps-ng openssl compat-openssl11 libbrotli git tar gzip zip xz unzip which shadow-utils bash zsh vim-enhanced vim-minimal wget jq ca-certificates podman buildah skopeo podman-docker fuse-overlayfs slirp4netns \
        && microdnf clean all \
        && rpm -q procps-ng openssl compat-openssl11 libbrotli git tar gzip zip xz unzip which shadow-utils bash zsh vim-enhanced vim-minimal wget jq ca-certificates podman buildah skopeo podman-docker fuse-overlayfs slirp4netns
    # Set 'base' module defined environment variables
    ENV \
        BUILDAH_ISOLATION="chroot" \
        HOME="/home/user"
    # Custom scripts from 'base' module
    USER root
    RUN [ "sh", "-x", "/tmp/scripts/base/init.sh" ]
###### /
###### END module 'base:v1.0'

###### START module 'ansible:v1.0'
###### \
    # Copy 'ansible' module content
    COPY modules/ansible /tmp/scripts/ansible
    # Switch to 'root' user for package management for 'ansible' module defined packages
    USER root
    # Install packages defined in the 'ansible' module
    RUN microdnf --disableplugin=subscription-manager --setopt=tsflags=nodocs --setopt=install_weak_deps=0 install -y python3-pip python3-devel \
        && microdnf clean all \
        && rpm -q python3-pip python3-devel
    # Custom scripts from 'ansible' module
    USER root
    RUN [ "sh", "-x", "/tmp/scripts/ansible/install.sh" ]
###### /
###### END module 'ansible:v1.0'

###### START module 'aws-cli:v1.0'
###### \
    # Copy 'aws-cli' module content
    COPY modules/aws-cli /tmp/scripts/aws-cli
    # Switch to 'root' user for package management for 'aws-cli' module defined packages
    USER root
    # Install packages defined in the 'aws-cli' module
    RUN microdnf --disableplugin=subscription-manager --setopt=tsflags=nodocs --setopt=install_weak_deps=0 install -y python3-pip python3-devel \
        && microdnf clean all \
        && rpm -q python3-pip python3-devel
    # Custom scripts from 'aws-cli' module
    USER root
    RUN [ "sh", "-x", "/tmp/scripts/aws-cli/install.sh" ]
###### /
###### END module 'aws-cli:v1.0'

###### START module 'java21:v1.0'
###### \
    # Switch to 'root' user for package management for 'java21' module defined packages
    USER root
    # Install packages defined in the 'java21' module
    RUN microdnf --disableplugin=subscription-manager --setopt=tsflags=nodocs --setopt=install_weak_deps=0 install -y java-21-openjdk-devel \
        && microdnf clean all \
        && rpm -q java-21-openjdk-devel
    # Set 'java21' module defined environment variables
    ENV \
        JAVA_HOME="/etc/alternatives/jre_21_openjdk"
###### /
###### END module 'java21:v1.0'

###### START module 'node20:v1.0'
###### \
    # Copy 'node20' module content
    COPY modules/node20 /tmp/scripts/node20
    ARG NODE_VERSION="v20.15.0"

    # Set 'node20' module defined environment variables
    ENV \
        PATH="${PATH}:/usr/local/node/bin"
    # Custom scripts from 'node20' module
    USER root
    RUN [ "sh", "-x", "/tmp/scripts/node20/install.sh" ]
###### /
###### END module 'node20:v1.0'

###### START module 'maven:v1.0'
###### \
    # Copy 'maven' module content
    COPY modules/maven /tmp/scripts/maven
    ARG MAVEN_VERSION="3.9.8"

    # Custom scripts from 'maven' module
    USER root
    RUN [ "sh", "-x", "/tmp/scripts/maven/install.sh" ]
###### /
###### END module 'maven:v1.0'

###### START module 'quarkus:v1.0'
###### \
    # Copy 'quarkus' module content
    COPY modules/quarkus /tmp/scripts/quarkus
    ARG QUARKUS_VERSION="3.8.5"

    # Set 'quarkus' module defined environment variables
    ENV \
        JBANG_DIR="/usr/local/jbang"
    # Custom scripts from 'quarkus' module
    USER root
    RUN [ "sh", "-x", "/tmp/scripts/quarkus/install.sh" ]
###### /
###### END module 'quarkus:v1.0'

###### START module 'podman-compose:v1.0'
###### \
    # Copy 'podman-compose' module content
    COPY modules/podman-compose /tmp/scripts/podman-compose
    # Switch to 'root' user for package management for 'podman-compose' module defined packages
    USER root
    # Install packages defined in the 'podman-compose' module
    RUN microdnf --disableplugin=subscription-manager --setopt=tsflags=nodocs --setopt=install_weak_deps=0 install -y python3-pip python3-devel podman aardvark-dns \
        && microdnf clean all \
        && rpm -q python3-pip python3-devel podman aardvark-dns
    # Custom scripts from 'podman-compose' module
    USER root
    RUN [ "sh", "-x", "/tmp/scripts/podman-compose/install.sh" ]
###### /
###### END module 'podman-compose:v1.0'

###### START image 'dev-tools/dev-workspace-nested:ubi9'
###### \
    # Set 'dev-tools/dev-workspace-nested' image defined labels
    LABEL \
        io.cekit.version="4.12.0"
###### /
###### END image 'dev-tools/dev-workspace-nested:ubi9'



# Switch to 'root' user and remove artifacts and modules
USER root
RUN rm -rf "/tmp/scripts" "/tmp/artifacts"
# Clear package manager metadata
RUN rm -rf "/var/cache/yum" "/var/lib/dnf" "/var/cache/apt" "/var/cache/dnf"

# Define the user
USER root
# Define entrypoint
ENTRYPOINT ["/entrypoint-nested.sh"]
# Define run cmd
CMD ["tail", "-f", "/dev/null"]
## /
## END target image