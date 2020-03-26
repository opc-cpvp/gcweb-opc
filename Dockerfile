FROM node:6

# Create the folder that will host our application and set the ownership to the node user
RUN mkdir -p /home/node/app/lib && \
	mkdir -p /home/node/app/node_modules && \
    chown -R node:node /home/node/app

# Set the working directory
WORKDIR /home/node/app

# Install OpenJDK 8 JRE & Python 2.7
RUN apt-get update && \
    apt-get install -y openjdk-8-jre python

# Install Bower & Grunt
RUN npm install -g bower grunt-cli && \
    npm cache clean --force

# Switch to the non-root user node
USER node

# Copy the over the code with the appropriate permissions
COPY --chown=node:node . .

# Install NPM packages and start Grunt server
ENTRYPOINT ["./entrypoint.sh"]
