# Stage 1: Build the Vite application
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and lock file
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the application for production
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine

# Copy built assets from the builder stage to the Nginx public directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Create a new Nginx configuration for a Single Page Application (SPA)
# This configuration ensures that all routes are directed to index.html
RUN echo "server { \n    listen 80; \n    server_name localhost; \n    root /usr/share/nginx/html; \n    index index.html; \n    location / { \n        try_files \$uri \$uri/ /index.html; \n    } \n}" > /etc/nginx/conf.d/app.conf

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
