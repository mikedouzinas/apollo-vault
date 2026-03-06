# Scripts Directory

Helper scripts for vault automation and web content capture.

## Available Scripts

### Attachment Management
Called via pnpm commands in package.json:
- `update-attachment-links.js` - Updates note links after moving attachments
- `fix-renamed-links.js` - Fixes links after renaming files

### Web Content Capture
Requires API keys:

#### firecrawl-scrape.sh
```bash
# Requires FIRECRAWL_API_KEY environment variable
.scripts/firecrawl-scrape.sh <url> <output_file>
```

#### firecrawl-batch.sh
```bash
# Requires FIRECRAWL_API_KEY environment variable
.scripts/firecrawl-batch.sh <url1> <url2> <url3>
# Files saved to 00_Inbox/Clippings/
```

### Transcript Extraction
#### transcript-extract.sh
```bash
.scripts/transcript-extract.sh <youtube-url>
```

## pnpm Scripts

| Command | Description |
|---------|-------------|
| `attachments:list` | Show first 20 unprocessed attachments |
| `attachments:count` | Count unprocessed attachments |
| `attachments:organized` | Count files in Organized folder |
| `attachments:sizes` | Show 20 largest attachment files |
| `attachments:orphans` | Find unreferenced attachments |
| `attachments:recent` | Show files added in last 7 days |
| `vault:stats` | Show vault statistics |

## Setup

### For Web Scraping
1. Get API key from [firecrawl.dev](https://firecrawl.dev)
2. Add to shell profile: `export FIRECRAWL_API_KEY="your-key-here"`

### For Transcript Extraction
```bash
# macOS
brew install yt-dlp jq

# Linux
apt-get install yt-dlp jq
```
