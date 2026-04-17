FROM node:18-alpine

# Install nginx and curl
RUN apk add --no-cache nginx curl

# Create app directory at the ROOT of the monorepo
WORKDIR /app

# Copy the root package files to install workspace dependencies
COPY package*.json ./
# If you have a pnpm-workspace.yaml or lerna.json, copy those too
# COPY pnpm-workspace.yaml ./ 

# Install dependencies for the whole workspace
RUN npm install && npm install -g tsx typescript

# Copy the ENTIRE project (this includes /lib and /services/api)
COPY . .

# Ensure the start script is executable
# Adjust this path if start.sh is inside your api service folder
RUN chmod +x ./services/api/start.sh

# Create folder for file uploads
RUN mkdir -p /app/services/api/files

# Configure Nginx
RUN rm -f /etc/nginx/http.d/default.conf
RUN echo 'server { \
    listen 30469; \
    \
    # Frontend / Dashboard \
    location / { \
        proxy_pass http://localhost:3000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
    \
    # ZIP downloads \
    location /files/ { \
        proxy_pass http://localhost:3000/files/; \
        add_header Content-Type application/octet-stream; \
        add_header Content-Disposition "attachment"; \
    } \
    \
    # External API Routing \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/http.d/default.conf

# Set the working directory to the API service before running
WORKDIR /app/services/api

EXPOSE 30469

# Run the startup script from within the service folder
CMD ["./start.sh"]
