FROM ubuntu:jammy
USER root

RUN apt-get update -qq && \
  apt-get install -y -qq wget curl build-essential && \
  rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/tinygo-org/tinygo/releases/download/v0.28.1/tinygo_0.28.1_amd64.deb && \
  dpkg -i tinygo_0.28.1_amd64.deb && \
  rm tinygo_0.28.1_amd64.deb

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y && \
  bash -c 'source $HOME/.cargo/env; rustup target add wasm32-wasi'

RUN wget -q -O OpenJDK.tar.gz https://download.bell-sw.com/java/17.0.8+7/bellsoft-jdk17.0.8+7-linux-amd64.tar.gz && \
  tar xzf OpenJDK.tar.gz && \
  mv jdk* /opt/ && \
  rm -f OpenJDK.tar.gz && \
  echo "export JAVA_HOME=$(dirname /opt/jdk-*/bin/)" | tee -a /root/.bashrc | tee -a /root/.profile > /dev/null && \
  echo 'export JRE_HOME=${JAVA_HOME}' | tee -a /root/.bashrc | tee -a /root/.profile > /dev/null && \
  echo 'export PATH=${PATH}:${JAVA_HOME}/bin' | tee -a /root/.bashrc | tee -a /root/.profile > /dev/null

RUN wget -q -O maven.tar.gz http://ftp.riken.jp/net/apache/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz && \
  tar xzf maven.tar.gz && \
  mv apache-maven-* /opt/ && \
  rm -f maven.tar.gz && \
  echo "export MAVEN_HOME=/opt/apache-maven-3.9.4" | tee -a /root/.bashrc | tee -a /root/.profile > /dev/null && \
  echo 'export PATH=${PATH}:${MAVEN_HOME}/bin' | tee -a /root/.bashrc | tee -a /root/.profile > /dev/null

RUN wget -q https://go.dev/dl/go1.20.7.linux-amd64.tar.gz && \
  rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.7.linux-amd64.tar.gz && \
  echo 'export PATH=${PATH}:/usr/local/go/bin' | tee -a /root/.bashrc | tee -a /root/.profile > /dev/null

RUN wget -q https://github.com/making/bfc/releases/download/0.1.0/bfc-x86_64-pc-linux && \
  mv bfc-x86_64-pc-linux /usr/local/bin/bfc && \
  chmod +x /usr/local/bin/bfc