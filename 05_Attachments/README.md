# Attachments

Images, PDFs, and other non-text files.

## Structure

- Root: Unprocessed attachments
- `Organized/`: Processed and categorized files

## Helper Commands

```bash
pnpm attachments:list        # List unprocessed files
pnpm attachments:organized   # Count organized files
pnpm attachments:orphans     # Find unreferenced files
pnpm attachments:sizes       # Find large files
```

## Tips

- Name files descriptively: `[RelatedNote]_[Description].[ext]`
- If using Gemini Vision, you can analyze images and PDFs directly
