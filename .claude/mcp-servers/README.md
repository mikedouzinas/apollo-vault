# MCP Servers

Optional Model Context Protocol servers for enhanced capabilities.

## Gemini Vision

Analyze images, PDFs, and videos using Google's Gemini model.

### Setup

1. Get a free API key from [Google AI Studio](https://aistudio.google.com/apikey)
2. Add to your shell profile:
   ```bash
   export GEMINI_API_KEY='your-key-here'
   ```
3. Reload shell: `source ~/.zshrc`
4. Add MCP server:
   ```bash
   claude mcp add --scope project gemini-vision node .claude/mcp-servers/gemini-vision.mjs
   ```

### Capabilities

- Analyze images and screenshots
- Extract text from PDFs
- Compare multiple images
- Analyze video content (local files and YouTube URLs)
- Generate smart filenames for images

### Quick Test

```bash
pnpm test-gemini
```

See `GEMINI_VISION_QUICK_START.md` for detailed usage examples.
