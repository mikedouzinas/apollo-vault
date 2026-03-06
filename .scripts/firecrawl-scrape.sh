#!/bin/bash

# Firecrawl scraper script that saves directly to file
# Usage: ./firecrawl-scrape.sh <url> <output_file>
# Requires: FIRECRAWL_API_KEY environment variable

URL="$1"
OUTPUT_FILE="$2"

if [ -z "$URL" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <url> <output_file>"
    echo "Requires FIRECRAWL_API_KEY environment variable to be set"
    exit 1
fi

if [ -z "$FIRECRAWL_API_KEY" ]; then
    echo "Error: FIRECRAWL_API_KEY environment variable not set"
    echo "Export it in your shell profile or run:"
    echo "  export FIRECRAWL_API_KEY='your-api-key'"
    exit 1
fi

# Make the API call and extract markdown using jq, save directly to file
curl -s -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"url\": \"$URL\",
    \"formats\": [\"markdown\"],
    \"onlyMainContent\": true
  }" | jq -r '.data.markdown // empty' > "$OUTPUT_FILE"

# Check if file was created and has content
if [ -s "$OUTPUT_FILE" ]; then
    echo "✓ Scraped content saved to: $OUTPUT_FILE"
else
    echo "✗ Failed to scrape content"
    rm -f "$OUTPUT_FILE"  # Remove empty file
    exit 1
fi
