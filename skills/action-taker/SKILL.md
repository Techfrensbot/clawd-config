---
name: action-taker
description: Take file actions (read, write, edit) in an organized workflow. Use when the user needs to perform sequential file operations or manage multiple file changes systematically.
---

# Action Taker

Execute file operations (read, write, edit) in a structured, organized way.

## Quick Actions

### Read a File

```bash
# Read entire file
cat path/to/file.txt

# Read specific lines
head -n 20 path/to/file.txt  # First 20 lines
tail -n 50 path/to/file.txt  # Last 50 lines
```

### Write a File

```bash
# Create new file
cat > path/to/newfile.txt << 'EOF'
Content here
EOF

# Overwrite existing
echo "New content" > path/to/file.txt
```

### Edit a File

**Simple edits:**
```bash
# Replace text
sed -i 's/old text/new text/g' path/to/file.txt

# Append to file
echo "New line" >> path/to/file.txt

# Insert at specific line
sed -i '10i\New line here' path/to/file.txt
```

**Use the `edit` tool for precise changes:**
- Safer than sed for complex edits
- Preserves file structure
- Clear before/after validation

## Workflow Pattern

**For multi-step operations:**

1. **Read** - Understand current state
   ```bash
   cat path/to/file.md
   ```

2. **Plan** - Identify what to change
   - What lines to modify?
   - What to add/remove?
   - What to preserve?

3. **Execute** - Make changes
   - Use `edit` tool for precise replacements
   - Use `write` for new files
   - Use append (`>>`) for additions

4. **Verify** - Confirm changes
   ```bash
   cat path/to/file.md  # Check result
   ```

## Common Patterns

### Create Multiple Related Files

```bash
# Create directory structure
mkdir -p project/{src,tests,docs}

# Write files
cat > project/src/main.py << 'EOF'
def main():
    print("Hello")
EOF

cat > project/tests/test_main.py << 'EOF'
def test_main():
    assert True
EOF
```

### Batch Edit Multiple Files

```bash
# Find and replace across files
for file in *.md; do
    sed -i 's/old/new/g' "$file"
done
```

### Safe Incremental Edits

1. Read current state
2. Edit one section
3. Verify change
4. Continue to next section

This prevents cascading errors from incorrect edits.

## Tips

- **Read before editing** - Always check current content first
- **Use exact text** - When using `edit` tool, match text exactly (including whitespace)
- **Verify changes** - Re-read file after edits to confirm
- **Small steps** - Better to do multiple small edits than one complex one
- **Backup important files** - Copy before major changes: `cp file.txt file.txt.bak`
