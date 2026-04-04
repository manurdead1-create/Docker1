FROM ubuntu:22.04

# Avoid interaction during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Copy your landing page into the default Nginx directory
COPY index.html /var/www/html/index.html

# Update Nginx to listen on your required port 30469 instead of 80
RUN sed -i 's/listen 80 default_server;/listen 30469 default_server;/g' /etc/nginx/sites-available/default
RUN sed -i 's/listen \[::\]:80 default_server;/listen [::]:30469 default_server;/g' /etc/nginx/sites-available/default

# Expose the port for Railway
EXPOSE 30469

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
