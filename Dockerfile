FROM debian:latest

#Instala software necesario para continuar con lo demas
RUN apt-get update && apt-get install -y dialog curl lsb-release gnupg2 apt-utils bash-completion sudo unzip vim make man

#Crea el usuario, le da sudo, setea confs
RUN adduser --shell /bin/bash julian && \
    echo 'julian:password' | chpasswd && \
    echo "julian ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "set mouse=r" >> /home/julian/.vimrc
COPY bashrc /home/julian/.bashrc

#Configura repos para gcloud e instala git openssh-server google-cloud-sdk kubectl
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y git google-cloud-sdk kubectl

#Instala terraform
ENV TERRAFORM_VERSION=0.11.13
ENV TERRAFORM_SHA256SUM=5925cd4d81e7d8f42a0054df2aafd66e2ab7408dbed2bd748f0022cfe592f8d2

RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
