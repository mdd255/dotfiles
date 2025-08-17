#!/usr/bin/env bash

# Build script for SurfingKeys configuration
# This script compiles index.ts and all its dependencies into a single config.js file

set -e

echo "🔨 Building SurfingKeys configuration..."

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Build the configuration
echo "🚀 Compiling TypeScript to config.js..."
npm run build

echo "✅ Build completed successfully!"
echo "📄 Output: config.js"

# Show file size
if [ -f "config.js" ]; then
    size=$(wc -c < config.js | tr -d ' ')
    echo "📊 File size: ${size} bytes"
fi
