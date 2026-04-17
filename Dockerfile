FROM node:18-alpine

# Install nginx and curl
RUN apk add --no-cache nginx curl

# Create app directory
WORKDIR /app

# 1. Copy package files first
COPY package*.json ./

# 2. Install dependencies for the whole workspace
RUN npm install && npm install -g tsx typescript

# 3. Copy the ENTIRE project (This includes /lib and your api folder)
COPY . .

# 4. FIX: Use find to locate start.sh and chmod it, regardless of folder depth
RUN find . -name "start.sh" -exec chmod +x {} +

# 5. Create folder for file uploads (Adjust path if needed)
RUN mkdir -p /app/files

# 6. Configure Nginx
RUN rm -f /etc/nginx/http.d/default.conf
RUN echo 'server { \
    listen 30469; \
    location / { \
        proxy_pass http://localhost:3000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
    location /files/ { \
        proxy_pass http://localhost:3000/files/; \
        add_header Content-Type application/octet-stream; \
    } \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
    } \
}' > /etc/nginx/http.d/default.conf

EXPOSE 30469

# 7. IMPORTANT: Set the WORKDIR to the folder containing your index.ts
# Replace "services/api" with the actual path to your api folder from the root
WORKDIR /app/services/api

# Run the startup script
CMD ["./start.sh"]
