# Claude Code User-Agent Patcher

A utility script to patch Claude Code's User-Agent header, enabling access to Wikimedia sites (Wikipedia, Wikidata, etc.) that enforce User-Agent requirements.

## Background

This project addresses [Wikimedia Phabricator T409871](https://phabricator.wikimedia.org/T409871), where Claude Code's WebFetch tool returns 403 errors when attempting to access Wikipedia and Wikidata content.

Wikimedia enforces a User-Agent policy to manage infrastructure usage fairly. The default axios User-Agent used by Claude Code does not meet their requirements, causing requests to be blocked. This script patches Claude Code to use a proper User-Agent header.

## Problem

When Claude Code tries to fetch content from Wikimedia sites, you might see:

```
Error: Request failed with status code 403
```

This happens because Wikimedia requires a descriptive User-Agent header to identify the client making requests.

## Solution

This script patches Claude Code's `cli.js` file to replace the default axios User-Agent with a Firefox User-Agent that is accepted by Wikimedia's infrastructure.

### What it does

1. **Locates** Claude Code's `cli.js` file
2. **Creates a backup** of the original file (if not already backed up)
3. **Patches** the User-Agent string from `axios/X.X.X` to a Firefox User-Agent
4. **Verifies** the patch was successful

## Installation & Usage

### Prerequisites

- Claude Code installed via npm
- Bash shell (Linux/macOS)
- `sed` and `grep` utilities

### Running the Patcher

1. Clone or download this repository:

   ```bash
   git clone <repository-url>
   cd claude-code-ua-patcher
   ```

2. Make the script executable:

   ```bash
   chmod +x patch-claude-user-agent.sh
   ```

3. Run the patcher:
   ```bash
   ./patch-claude-user-agent.sh
   ```

### Expected Output

**First run:**

```
Claude Code User-Agent Patcher
===============================

Creating backup at /home/user/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js.original...
✓ Backup created

Applying patch...
✓ Successfully patched!

User-Agent is now set to:
  Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0

To restore the original, run:
  cp /home/user/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js.original /home/user/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js
```

**Already patched:**

```
✓ Already patched! User-Agent is set to:
  Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0
```

## Configuration

You can customize the User-Agent string by editing the script:

```bash
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0"
```

If Claude Code is installed in a non-standard location, update:

```bash
CLAUDE_CLI_PATH="${HOME}/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js"
```

## Restoring Original

To restore the original Claude Code behavior:

```bash
cp ~/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js.original \
   ~/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js
```

(Adjust the path to match your installation)

## Important Notes

### Updates

After updating Claude Code via npm, you'll need to **re-run this patcher** as the update will overwrite the patched file.

### Safety

- The script creates a backup before patching (`.original` file)
- It checks if already patched to avoid double-patching
- It verifies the patch was applied successfully
- On failure, it automatically restores from backup

### Limitations

- Only tested with specific Claude Code versions
- May break if Claude Code's internal structure changes significantly
- The script looks for a specific pattern: `O.set("User-Agent","axios/`

## Testing

After patching, test by asking Claude Code to fetch Wikipedia content:

```
Can you fetch and summarize the Wikipedia page about Machine Learning?
```

Claude Code should now be able to successfully access and retrieve the content.

## Troubleshooting

### "Error: Claude Code cli.js not found"

Update the `CLAUDE_CLI_PATH` variable in the script to point to your actual Claude Code installation.

Find it with:

```bash
find ~ -name "cli.js" -path "*/claude-code/*" 2>/dev/null
```

### "Warning: Expected axios User-Agent pattern not found"

The Claude Code internals may have changed. The script will show you any User-Agent patterns it finds. You may need to manually inspect and update the sed pattern.

### Patch doesn't seem to work

1. Verify the patch was applied: `grep "User-Agent" <path-to-cli.js> | head -5`
2. Restart Claude Code completely
3. Check if Claude Code was updated and needs re-patching

## Contributing

Issues and pull requests welcome! This is a workaround solution until Claude Code officially implements proper User-Agent handling upstream.

## License

MIT

## See Also

- [Wikimedia User-Agent Policy](https://meta.wikimedia.org/wiki/User-Agent_policy)
- [Phabricator T409871](https://phabricator.wikimedia.org/T409871) - Original issue report
