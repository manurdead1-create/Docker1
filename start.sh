#!/bin/sh

# Add the --skip-project flag to bypass environment-specific compiler errors
ts-node --transpile-only --skip-project src/index.ts &

nginx -g "daemon off;"
