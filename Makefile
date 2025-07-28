.PHONY: all clean build-mcp build-http pack-mcp pack-http test-http

all: install build pack

# Install dependencies (including dev dependencies for build)
install:
	npm ci

# Install only production dependencies (for runtime/packaging)
install-prod:
	npm ci --omit=dev

# Build Weather MCP server
build: install
	npm run build

# Pack MCP server for Claude Desktop (production dependencies only)
pack: build install-prod
	@echo "Packing MCP server for Claude Desktop..."
	zip -r weather-mcp-js-server.dxt manifest.json icon.png package.json node_modules/ build/

# Test
test: build
	npx @modelcontextprotocol/inspector node build/index.js
		
clean:
	rm -f *.dxt *.zip
	rm -rf node_modules build

proxy:
	mitmweb -p 8888 --mode reverse:http://localhost:8000 --web-port 8081

sgw-sse:
	npx -y supergateway \
    --stdio "node build/index.js" \
    --port 8000 --baseUrl http://localhost:8000 \
    --ssePath /sse --messagePath /message

sgw-mcp:
	npx -y supergateway \
	--stdio "node build/index.js" \
    --outputTransport streamableHttp \
    --port 8000

help:
	@echo "Usage:"
	@echo "  make all           - Build All"
	@echo "  make install       - Install all dependencies (including dev) with npm ci"
	@echo "  make install-prod  - Install only production dependencies with npm ci"
	@echo "  make build         - Build the Weather MCP server"
	@echo "  make pack          - Pack the MCP server for Claude Desktop"
	@echo "  make test-sse      - Test the SSE server locally"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make proxy         - Start mitmproxy for debugging"
	@echo "  make sgw-sse       - Start Supergateway for SSE"
	@echo "  make sgw-mcp       - Start Supergateway for MCP"
	@echo "  make help          - Show this help message"