# C64 font rotator

A project to create a tool which can perform transformation on C64
font files. This repository is used for improving my vibe-coding
skills.
 
The final app is available at https://pararaum.github.io/c64-font-tumbler/.

# Configuration and building #

My current mode of development is to use a Docker image and have the
tools installed there. Then a container is run with the repository
mounted as a volume at "/app". The Dockerfile is:
  
```Dockerfile
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
```

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
