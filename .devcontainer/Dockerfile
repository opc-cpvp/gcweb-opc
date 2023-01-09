FROM node:8

RUN npm install -g \
    grunt-cli@1.3.2 \
    bower@1.8.12 \
    && npm cache clean --force

RUN echo 'deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_DEBIAN_VERSION 8u332-ga-1~deb9u1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20161107~bpo8+1

RUN apt-get update; \
    apt-get install -y \
    openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
    ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
    ; \
    rm -rf /var/lib/apt/lists/*;

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN echo 'unsafe-perm=true' > /root/.npmrc