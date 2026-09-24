# Use an official Node.js runtime as a parent image
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json files into the container
COPY package*.json ./

# Install the dependencies
RUN npm ci

# Copy the rest of the application code into the container
COPY . .

ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

# Build the application
RUN npm run build

# Use a lightweight web server to serve the built application
FROM nginx:alpine

# Copy the built application from the builder stage to the Nginx HTML directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose the port the app runs on
EXPOSE 80

# Set the command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
