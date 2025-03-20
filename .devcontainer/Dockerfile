FROM node:6

# Retrieve root certificate
RUN echo | \
	openssl s_client -showcerts -connect www.google.com:443 2>&1 | \
	tac | \
	sed -ne '/-END CERTIFICATE-/,${p;/-BEGIN CERTIFICATE-/q}' | \
	tac > /usr/local/share/ca-certificates/root-ca.crt

# Append the root certificate to ca-certificates.crt
RUN cat /usr/local/share/ca-certificates/root-ca.crt >> /etc/ssl/certs/ca-certificates.crt

# Set NODE_EXTRA_CA_CERTS to ca-certificates.crt
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# Install additional tools
RUN npm install -g \
	grunt-cli@1.3.2 \
	bower@1.8.12 \
	&& npm cache clean --force

RUN echo 'deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
RUN echo 'deb [check-valid-until=no] http://archive.debian.org/debian stretch main' > /etc/apt/sources.list.d/stretch.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_DEBIAN_VERSION 8u171-b11-1~bpo8+1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20161107~bpo8+1

RUN apt-get update; \
	apt-get install -y --allow-unauthenticated \
	openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
	ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
	; \
	rm -rf /var/lib/apt/lists/*;

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Set the working directory to our workspace
WORKDIR /workspaces/gcweb-opc

# Create the node_modules directory and set the owner to the node user
RUN mkdir node_modules && chown -R node:node node_modules

# Create the lib directory and set the owner to the node user
RUN mkdir lib && chown -R node:node lib
