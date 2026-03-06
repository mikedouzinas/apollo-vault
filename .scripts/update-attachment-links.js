#!/usr/bin/env node

/**
 * Updates attachment links in markdown files after files are moved to Organized folder
 * Usage: node .scripts/update-attachment-links.js [specific-file.ext]
 *
 * If no argument provided, updates all files in Organized folder
 * If specific filename provided, only updates references to that file
 */

import fs from 'fs';
import path from 'path';

const organizedDir = '05 Attachments/Organized';
const args = process.argv.slice(2);
const specificFile = args[0];

// Get list of files to update references for
let filesToUpdate = [];

if (specificFile) {
    // Update references for a specific file
    filesToUpdate = [specificFile];
    console.log(`Updating references for: ${specificFile}`);
} else {
    // Update references for all files in Organized folder
    if (fs.existsSync(organizedDir)) {
        filesToUpdate = fs.readdirSync(organizedDir);
        console.log(`Found ${filesToUpdate.length} files in Organized folder`);
    } else {
        console.log('Organized folder does not exist yet');
        process.exit(0);
    }
}

// Function to walk directory
function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        const dirPath = path.join(dir, f);
        const isDirectory = fs.statSync(dirPath).isDirectory();
        if (isDirectory) {
            // Skip node_modules, .git, and the Organized folder itself
            if (!f.includes('node_modules') && !f.includes('.git') && dirPath !== organizedDir) {
                walkDir(dirPath, callback);
            }
        } else {
            callback(path.join(dir, f));
        }
    });
}

// Process all markdown files
let updatedCount = 0;
const updatedFiles = [];

walkDir('.', (filepath) => {
    if (filepath.endsWith('.md')) {
        let content = fs.readFileSync(filepath, 'utf8');
        const originalContent = content;

        // For each file to update, fix references
        filesToUpdate.forEach(filename => {
            // Escape special regex characters in filename
            const escapedFile = filename.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

            // Pattern 1: ![[filename]] without path
            const pattern1 = new RegExp(`!\\[\\[${escapedFile}\\]\\]`, 'g');
            content = content.replace(pattern1, `![[05 Attachments/Organized/${filename}]]`);

            // Pattern 2: ![[05 Attachments/filename]] (file in root being moved)
            const pattern2 = new RegExp(`!\\[\\[05 Attachments/${escapedFile}\\]\\]`, 'g');
            content = content.replace(pattern2, `![[05 Attachments/Organized/${filename}]]`);

            // Pattern 3: [[filename]] without ! (for PDFs and other non-embedded links)
            // Only if not already pointing to Organized
            const pattern3 = new RegExp(`\\[\\[${escapedFile}\\]\\]`, 'g');
            const pattern3Organized = new RegExp(`\\[\\[05 Attachments/Organized/${escapedFile}\\]\\]`, 'g');

            // Only replace if not already pointing to Organized and not preceded by !
            if (!pattern3Organized.test(content)) {
                content = content.replace(pattern3, `[[05 Attachments/Organized/${filename}]]`);
            }

            // Pattern 4: [[05 Attachments/filename]] without !
            const pattern4 = new RegExp(`\\[\\[05 Attachments/${escapedFile}\\]\\]`, 'g');
            content = content.replace(pattern4, `[[05 Attachments/Organized/${filename}]]`);
        });

        // Write back if changed
        if (content !== originalContent) {
            fs.writeFileSync(filepath, content, 'utf8');
            updatedFiles.push(filepath);
            updatedCount++;
        }
    }
});

// Report results
if (updatedCount > 0) {
    console.log(`\nUpdated ${updatedCount} files:`);
    updatedFiles.forEach(file => console.log(`  - ${file}`));
} else {
    console.log('\nNo files needed updating');
}

console.log('\nDone!');
