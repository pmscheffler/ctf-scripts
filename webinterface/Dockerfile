# Use Node.js base image
FROM alpine

run apk install node npm bash jq 

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application files
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Command to start the application
CMD ["node", "app.js"]
