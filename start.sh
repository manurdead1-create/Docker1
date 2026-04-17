#!/bin/sh

# Start the TypeScript API from the src folder
ts-node --esm --transpile-only src/index.ts &

# Start Nginx
nginx -g "daemon off;"
