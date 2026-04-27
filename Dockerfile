FROM node:alpine

# Install Vue CLI and other dependencies globally
RUN npm install -g @vue/cli

# Set working directory
WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the default Vue.js dev server port
EXPOSE 8080

# Start the Vue.js dev server
CMD ["npm", "run", "serve"]
