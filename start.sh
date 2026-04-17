#!/bin/sh

# Start the TypeScript API in the background
# This runs src/index.ts using ts-node
ts-node --project tsconfig.json src/index.ts &

# Start Nginx in the foreground
nginx -g "daemon off;"
