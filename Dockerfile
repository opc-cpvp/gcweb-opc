FROM opccpvp/gcweb-opc-build:v4.0.26

# Create the folder that will host our application and set the ownership to the node user
RUN mkdir -p /home/node/app/lib && \
    mkdir -p /home/node/app/node_modules && \
    chown -R node:node /home/node/app

# Set the working directory
WORKDIR /home/node/app

# Switch to the non-root user node
USER node

# Copy the over the code with the appropriate permissions
COPY --chown=node:node . .

# Install NPM packages and start Grunt server
ENTRYPOINT ["./entrypoint.sh"]
