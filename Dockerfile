FROM dorowu/ubuntu-desktop-lxde-vnc

# 1. Environment variables for the Desktop
ENV RESOLUTION=1280x800
ENV USER=root
ENV PASSWORD=root

# 2. Install Nginx since we aren't using the nginx:alpine base anymore
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# 3. Copy your web files to the standard Nginx directory
COPY . /usr/share/nginx/html

# 4. Create your custom Nginx configuration
RUN echo 'server { \
    listen 30469; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/sites-available/default

# 5. Expose the requested port
EXPOSE 30469

# Note: The base image (dorowu/ubuntu-desktop-lxde-vnc) has its own 
# ENTRYPOINT/CMD to start the desktop. Nginx will likely need to be 
# started manually or via a startup script if it doesn't boot automatically.
