FROM node:18-alpine

RUN apk add --no-cache nginx curl

WORKDIR /app

# 1. Copy everything from your local root to /app in Docker
COPY . .

# 2. Install dependencies
RUN npm install && npm install -g tsx typescript

# 3. Configure Nginx
RUN rm -f /etc/nginx/http.d/default.conf
RUN echo 'server { \
    listen 30469; \
    location / { \
        proxy_pass http://127.0.0.1:3000; \
        proxy_set_header Host $host; \
    } \
    location /api/ { \
        proxy_pass http://176.100.37.91:30469; \
        proxy_set_header Host $host; \
    } \
}' > /etc/nginx/http.d/default.conf

# 4. FIND the start.sh file and move it to the root of /app 
# This prevents the "No such file" error regardless of your folder structure
RUN find . -name "start.sh" -exec cp {} /app/start.sh \;
RUN chmod +x /app/start.sh

# 5. Set Workdir to where your code is (usually /app/services/api)
# But we will run the script from /app
WORKDIR /app/services/api

EXPOSE 30469

# 6. Run the script using the absolute path we created in step 4
CMD ["/bin/sh", "/app/start.sh"]
