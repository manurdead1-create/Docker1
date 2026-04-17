#!/bin/sh

# Start the TS API on port 3000 (Internal)
# tsx will resolve your @workspace/api-zod paths automatically
tsx src/index.ts &

# Start Nginx on port 30469 (External)
# This matches your Railway custom domain port
nginx -g "daemon off;"
