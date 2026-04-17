FROM node:18-alpine

# Install nginx and curl
RUN apk add --no-cache nginx curl

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies and the robust TS runner 'tsx'
RUN npm install && \
    npm install -g tsx typescript

# Copy all project files (src, tsconfig.json, start.sh, etc.)
COPY . . 

# Ensure the start script is executable
RUN chmod +x start.sh

# Create folder for file uploads
RUN mkdir -p /app/files

# Configure Nginx with your specific External API IP
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
    # Your External API Server \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/http.d/default.conf

# Expose the external port
EXPOSE 30469

# Run the startup script
CMD ["./start.sh"]
