# SurfingKeys Configuration Makefile

.PHONY: build watch clean install dev

# Default target
all: build

# Install dependencies
install:
	@echo "📦 Installing SurfingKeys dependencies..."
	@npm install

# Build the configuration
build: install
	@echo "🔨 Building SurfingKeys configuration..."
	@npm run build

# Watch for changes and rebuild automatically
watch: install
	@echo "👀 Watching for changes..."
	@npm run watch

# Development mode (alias for watch)
dev: watch

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -f config.js
	@rm -rf node_modules
	@rm -f package-lock.json

# Check if config.js is up to date
check:
	@if [ ! -f config.js ]; then \
		echo "❌ config.js not found. Run 'make build' first."; \
		exit 1; \
	elif [ index.ts -nt config.js ] || [ bindings.ts -nt config.js ] || [ theme.ts -nt config.js ]; then \
		echo "⚠️  config.js is outdated. Run 'make build' to update."; \
		exit 1; \
	else \
		echo "✅ config.js is up to date."; \
	fi

# Show help
help:
	@echo "SurfingKeys Configuration Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build    - Build config.js from TypeScript sources"
	@echo "  watch    - Watch for changes and rebuild automatically"
	@echo "  dev      - Development mode (alias for watch)"
	@echo "  install  - Install npm dependencies"
	@echo "  clean    - Remove build artifacts and dependencies"
	@echo "  check    - Check if config.js is up to date"
	@echo "  help     - Show this help message"
