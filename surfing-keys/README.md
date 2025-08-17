# SurfingKeys Configuration

This directory contains TypeScript-based configuration for SurfingKeys browser extension.

## Structure

- `index.ts` - Main entry point that imports all configuration modules
- `bindings.ts` - Custom key bindings and search aliases
- `theme.ts` - Visual theme and styling configuration
- `types.d.ts` - TypeScript declarations for SurfingKeys API
- `config.js` - Generated configuration file (output)

## Build System

The configuration is built from TypeScript sources into a single `config.js` file using esbuild.

### Commands

```bash
# Build the configuration
make build
# or
npm run build

# Watch for changes and rebuild automatically
make watch
# or
make dev
# or
npm run watch

# Install dependencies
make install

# Clean build artifacts
make clean

# Check if config.js is up to date
make check

# Show help
make help
```

### Quick Start

1. Install dependencies and build:
   ```bash
   cd surfing-keys
   make build
   ```

2. The generated `config.js` file can be used directly with SurfingKeys extension.

3. For development, use watch mode:
   ```bash
   make watch
   ```

## Configuration

### Key Bindings (`bindings.ts`)

Add your custom key mappings and search aliases in this file. Examples:

```typescript
// Custom search engines
api.addSearchAlias('g', 'google', 'https://www.google.com/search?q=', 's');
api.addSearchAlias('gh', 'github', 'https://github.com/search?q=', 's');

// Custom key mappings
api.map('J', 'E'); // Move to next tab
api.map('K', 'R'); // Move to previous tab
```

### Theme (`theme.ts`)

Customize the visual appearance of SurfingKeys UI elements in this file.

## Development

The build system uses:
- **esbuild** for fast bundling and compilation
- **TypeScript** for type checking and modern JavaScript features
- **Make** for task automation

The TypeScript configuration includes type definitions for the SurfingKeys API, providing IntelliSense and type checking during development.
