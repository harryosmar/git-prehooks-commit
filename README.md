# Git Pre-Commit Hooks

Automated Git hooks that enforce commit message conventions and code quality standards.

## Features

- ✅ **Commit Message Validation** - Enforces Jira ticket format (CDE-XXXXX) with optional commit types
- ✅ **Conventional Commits** - Support for feat, fix, hotfix, docs, and more
- ✅ **Code Quality Checks** - Detects debug statements, TODOs, trailing whitespace
- ✅ **Security Checks** - Blocks commits with hardcoded credentials
- ✅ **Branch Protection** - Prevents direct commits to protected branches
- ✅ **Configurable** - All rules customizable via `.githooks-config.json`

---

## Installation

### Quick Setup

```bash
# 1. Navigate to your repository
cd /path/to/your/repo

# 2. Run the setup script
./setup-hooks.sh

# 3. Done! Hooks are now active
```

### Manual Setup

```bash
# Copy hooks to .git/hooks/
cp hooks-templates/commit-msg .git/hooks/
cp hooks-templates/pre-commit .git/hooks/

# Make them executable
chmod +x .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit
```

---

## Configuration

Edit `.githooks-config.json` to customize behavior:

```json
{
  "commit-msg": {
    "jira_project": "CDE",
    "min_message_length": 10,
    "max_subject_length": 72,
    "require_type": true,
    "allowed_types": ["feat", "fix", "hotfix", "docs", "style", "refactor", "perf", "test", "chore", "build", "ci", "revert", "security"]
  },
  "pre-commit": {
    "protected_branches": ["develop", "master", "micro-qa", "micro-qa-adhoc"],
    "checks": {
      "conflict_markers": { "enabled": true, "blocking": true },
      "debug_statements": {
        "enabled": true,
        "blocking": false,
        "patterns": ["console\\.log", "debugger", "print\\(", "var_dump", "dd\\(", "dump\\("]
      },
      "todo_comments": {
        "enabled": true,
        "blocking": false,
        "patterns": ["TODO", "FIXME", "XXX", "HACK"]
      },
      "large_files": {
        "enabled": true,
        "blocking": false,
        "max_size_bytes": 5242880
      },
      "sensitive_data": {
        "enabled": true,
        "blocking": false,
        "patterns": ["password", "api_key", "secret", "token", "private_key"]
      },
      "trailing_whitespace": { "enabled": true, "blocking": false }
    }
  }
}
```

### Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `jira_project` | Jira project code | `CDE` |
| `min_message_length` | Min chars after ticket | `10` |
| `max_subject_length` | Max subject length | `72` |
| `require_type` | Require commit type | `true` |
| `allowed_types` | List of valid commit types | `["feat", "fix", "hotfix", ...]` |
| `protected_branches` | Branches to protect | `["develop", "master", "micro-qa", "micro-qa-adhoc"]` |
| `enabled` | Enable/disable check | `true` |
| `blocking` | Block commit on failure | `true/false` |
| `patterns` | Detection patterns | Varies by check |
| `max_size_bytes` | Max file size | `5242880` (5MB) |

---

## Rules & Checks

### 1. Commit Message Validation

**Format Required:** `CDE-XXXXX: type: Your commit message`

**Rules:**
- Must start with Jira ticket (e.g., `CDE-123:`)
- Must include commit type (e.g., `feat:`, `fix:`, `hotfix:`)
- Minimum 10 characters after ticket and type
- Maximum 72 characters for subject line (warning)
- First letter should be capitalized (warning)
- Use imperative mood (warning)
- No period at end of subject (warning)

**Commit Types:**

| Type | Description | Example |
|------|-------------|----------|
| `feat` | New feature | `CDE-123: feat: Add user authentication` |
| `fix` | Bug fix | `CDE-456: fix: Resolve login timeout` |
| `hotfix` | Critical production fix | `CDE-789: hotfix: Fix payment crash` |
| `docs` | Documentation | `CDE-101: docs: Update API docs` |
| `style` | Code formatting | `CDE-202: style: Format with prettier` |
| `refactor` | Code refactoring | `CDE-303: refactor: Simplify auth logic` |
| `perf` | Performance | `CDE-404: perf: Optimize queries` |
| `test` | Tests | `CDE-505: test: Add auth unit tests` |
| `chore` | Maintenance | `CDE-606: chore: Update dependencies` |
| `build` | Build system | `CDE-707: build: Update webpack` |
| `ci` | CI/CD | `CDE-808: ci: Add GitHub Actions` |
| `revert` | Revert commit | `CDE-909: revert: Revert commit abc123` |
| `security` | Security fix | `CDE-111: security: Fix XSS` |

**✅ Valid Examples:**
```bash
CDE-123: feat: Add user authentication
CDE-456: fix: Resolve login validation bug
CDE-789: docs: Update API documentation
CDE-101: hotfix: Fix critical payment issue
CDE-202: refactor: Simplify database queries
```

**❌ Invalid Examples:**
```bash
Add feature                         # Missing Jira ticket
CDE-123 Add feature                # Missing colon
CDE-123: Add feature               # Missing type
CDE-123: feature: Add auth         # Invalid type (use 'feat')
CDE-123: fix: bug                  # Too short (< 10 chars)
CDE-123: FIX: Resolve bug          # Type must be lowercase
```

**Disable Type Requirement:**

If you don't want to enforce commit types, set `require_type: false` in config:

```json
{
  "commit-msg": {
    "jira_project": "CDE",
    "require_type": false
  }
}
```

Then format becomes: `CDE-123: Your commit message`

### 2. Protected Branch Check

**Blocks direct commits to:**
- `develop`
- `master`
- `micro-qa`
- `micro-qa-adhoc`

**Solution:** Create a feature branch
```bash
git checkout -b feature/CDE-123-description
```

### 3. Merge Conflict Markers

**Detects:** `<<<<<<<`, `=======`, `>>>>>>>`

**Blocking:** ✅ Yes

**Example Output:**
```
✗ Merge conflict markers found in 1 file(s):

  • src/app.js
```

### 4. Debug Statements

**Detects:** `console.log`, `debugger`, `print()`, `var_dump`, `dd()`, `dump()`

**Blocking:** ⚠️ No (warning only)

**Example Output:**
```
⚠ Warning: Debug statements found in 2 file(s):

  • src/app.js
  • src/utils.py

Consider removing them before committing
```

### 5. TODO/FIXME Comments

**Detects:** `TODO`, `FIXME`, `XXX`, `HACK`

**Blocking:** ⚠️ No (warning only)

**Example Output:**
```
⚠ Warning: Found 3 new TODO/FIXME comment(s) in 2 file(s):

  • src/app.js (2 comment(s))
  • src/utils.py (1 comment(s))

Make sure they are tracked in your issue tracker
```

### 6. Large Files

**Detects:** Files larger than 5MB

**Blocking:** ⚠️ No (warning only)

**Example Output:**
```
⚠ Warning: Large files detected (1 file(s)):

  • assets/video.mp4 (10.5MiB)

Consider using Git LFS for large files
```

### 7. Sensitive Data

**Detects:** `password`, `api_key`, `secret`, `token`, `private_key`, `aws_access_key_id`, `aws_secret_access_key`

**Blocking:** ⚠️ Configurable (default: warning)

**Example Output:**
```
⚠ Warning: Potential sensitive data found in 2 file(s):

File: config.js
+const api_key = "sk_live_abc123xyz789"

File: auth.py
+password = "mySecretPass123"

Please review and remove any hardcoded credentials!
```

### 8. Empty Files

**Detects:** Files with zero bytes

**Blocking:** ⚠️ No (warning only)

**Example Output:**
```
⚠ Warning: Empty files detected (1 file(s)):

  • empty.txt
```

### 9. Trailing Whitespace

**Detects:** Spaces/tabs at end of lines

**Blocking:** ⚠️ No (warning only)

**Example Output:**
```
⚠ Warning: Found trailing whitespace in 2 file(s) (5 line(s)):

  • src/app.js
  • src/utils.py

Run: git diff --cached --check
```

---

## Usage Examples

### Normal Workflow

```bash
# 1. Create feature branch
git checkout -b feature/CDE-123-user-auth

# 2. Make changes
vim src/auth.js

# 3. Stage changes
git add src/auth.js

# 4. Commit with proper format (with type)
git commit -m "CDE-123: feat: Add JWT authentication"

# Output:
# 🚀 Running pre-commit checks...
# ✓ No conflict markers found
# ✓ No debug statements found
# ✓ All checks passed!
# 🔍 Validating commit message...
# ✓ Commit message validated successfully!
# Ticket: CDE-123
# Type: feat
# Message: Add JWT authentication
```

### Handling Warnings

```bash
# If you get warnings, you can still commit
git commit -m "CDE-456: Add feature with TODO"

# Output:
# ⚠ Warning: Found 1 new TODO/FIXME comment(s)
# ✅ All pre-commit checks passed!
```

### Handling Errors

```bash
# Error 1: Missing Jira ticket
git commit -m "Add feature"
# Output: ✗ Commit message must start with Jira ticket format: CDE-XXXXX:

# Error 2: Missing commit type
git commit -m "CDE-123: Add feature"
# Output: ✗ Commit message must include a type
# Allowed types: feat, fix, hotfix, docs, style, refactor, perf, test, chore, build, ci, revert, security

# Error 3: Invalid commit type
git commit -m "CDE-123: feature: Add auth"
# Output: ✗ Invalid commit type 'feature'
# Allowed types: feat, fix, hotfix, docs, ...

# Fix and retry
git commit -m "CDE-123: feat: Add user authentication"
# Output: ✅ Commit message validated successfully!
```

### Bypassing Hooks (Emergency Only)

```bash
# Skip all hooks (NOT RECOMMENDED)
git commit --no-verify -m "Emergency hotfix"
```

⚠️ **Warning:** Only bypass hooks in genuine emergencies!

---

## Testing

### Test Commit Message Validation

```bash
# Test 1: Missing Jira ticket (should fail)
git commit --allow-empty -m "Add feature"
# Expected: ❌ Rejected - Missing Jira ticket

# Test 2: Missing type (should fail)
git commit --allow-empty -m "CDE-123: Add feature"
# Expected: ❌ Rejected - Missing commit type

# Test 3: Invalid type (should fail)
git commit --allow-empty -m "CDE-123: feature: Add auth"
# Expected: ❌ Rejected - Invalid type

# Test 4: Valid format (should pass)
git commit --allow-empty -m "CDE-123: feat: Add feature"
# Expected: ✅ Accepted

# Test 5: Different types (should pass)
git commit --allow-empty -m "CDE-456: fix: Resolve bug"
git commit --allow-empty -m "CDE-789: docs: Update README"
git commit --allow-empty -m "CDE-101: hotfix: Fix critical issue"
# Expected: ✅ All accepted
```

### Test Protected Branch

```bash
# Test on master (should fail)
git checkout master
git commit --allow-empty -m "CDE-123: Test"
# Expected: ❌ Blocked

# Test on feature branch (should pass)
git checkout -b feature/test
git commit --allow-empty -m "CDE-123: Test"
# Expected: ✅ Accepted
```

### Test Debug Statement Detection

```bash
# Create file with debug statement
echo 'console.log("test");' > test.js
git add test.js
git commit -m "CDE-123: Test debug detection"
# Expected: ⚠️ Warning shown, commit allowed
```

### Test Sensitive Data Detection

```bash
# Create file with sensitive data
echo 'const api_key = "sk_live_abc123xyz789";' > config.js
git add config.js
git commit -m "CDE-123: Test sensitive data"
# Expected: ⚠️ Warning shown (or ❌ blocked if configured)
```

### Test Large File Detection

```bash
# Create large file (6MB)
dd if=/dev/zero of=large.bin bs=1m count=6
git add large.bin
git commit -m "CDE-123: Test large file"
# Expected: ⚠️ Warning shown
```

### Test Trailing Whitespace

```bash
# Create file with trailing whitespace
echo "line with spaces   " > test.txt
git add test.txt
git commit -m "CDE-123: Test whitespace"
# Expected: ⚠️ Warning shown
```

### Test TODO Comments

```bash
# Create file with TODO
echo "// TODO: Fix this later" > test.js
git add test.js
git commit -m "CDE-123: Test TODO detection"
# Expected: ⚠️ Warning shown
```

---

## Customization

### Change Jira Project

```json
{
  "commit-msg": {
    "jira_project": "PROJ",
    "min_message_length": 10,
    "max_subject_length": 72,
    "require_type": true,
    "allowed_types": ["feat", "fix", "hotfix", "docs"]
  }
}
```

Now commits must use: `PROJ-123: type: Message`

### Disable Commit Type Requirement

```json
{
  "commit-msg": {
    "jira_project": "CDE",
    "require_type": false
  }
}
```

Now commits can use: `CDE-123: Message` (without type)

### Customize Allowed Types

```json
{
  "commit-msg": {
    "require_type": true,
    "allowed_types": ["feat", "fix", "hotfix", "docs", "wip"]
  }
}
```

Now only these types are allowed: feat, fix, hotfix, docs, wip

### Add More Protected Branches

```json
{
  "pre-commit": {
    "protected_branches": ["develop", "master", "staging", "production"]
  }
}
```

### Make Sensitive Data Blocking

```json
{
  "sensitive_data": {
    "enabled": true,
    "blocking": true,
    "patterns": ["password", "api_key", "secret"]
  }
}
```

### Add Custom Debug Patterns

```json
{
  "debug_statements": {
    "enabled": true,
    "blocking": false,
    "patterns": ["console\\.log", "debugger", "alert\\(", "System\\.out\\.println"]
  }
}
```

### Disable Specific Checks

```json
{
  "trailing_whitespace": {
    "enabled": false,
    "blocking": false
  }
}
```

### Change File Size Limit

```json
{
  "large_files": {
    "enabled": true,
    "blocking": false,
    "max_size_bytes": 10485760
  }
}
```

This sets the limit to 10MB (10 * 1024 * 1024 bytes).

---

## Troubleshooting

### Hooks Not Running

```bash
# Check if hooks are executable
ls -la .git/hooks/commit-msg
ls -la .git/hooks/pre-commit

# Make them executable
chmod +x .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit
```

### Config Not Being Read

```bash
# Verify config file exists
cat .githooks-config.json

# Verify JSON is valid
python -m json.tool .githooks-config.json
```

### False Positives

If a check incorrectly flags your code:

1. Review the pattern in `.githooks-config.json`
2. Adjust or remove the pattern
3. Or temporarily bypass with `--no-verify` (document why)

---

## Team Setup

Since Git hooks are local and not tracked by Git:

1. **Add to onboarding docs**: Include hook setup in new developer onboarding
2. **Run setup script**: Each team member must run `./setup-hooks.sh`
3. **Keep templates updated**: Commit changes to `hooks-templates/` directory
4. **Document exceptions**: If someone bypasses hooks, document the reason

---

## Files Structure

```
.
├── .githooks-config.json       # Configuration file
├── .gitignore                  # Git ignore rules
├── setup-hooks.sh              # Installation script
├── hooks-templates/            # Hook templates (git-trackable)
│   ├── commit-msg              # Commit message validator
│   └── pre-commit              # Pre-commit quality checks
└── README.md                   # This file
```

---

## FAQ

**Q: Can I bypass the hooks?**  
A: Yes, use `git commit --no-verify`, but only in emergencies.

**Q: Do hooks run on `git merge`?**  
A: The commit-msg hook skips merge commits automatically.

**Q: Can I use a different Jira project?**  
A: Yes, change `jira_project` in `.githooks-config.json`.

**Q: What if I don't use Jira?**  
A: You can modify the commit-msg hook to use a different format.

**Q: Are hooks shared with the team?**  
A: No, each team member must run the setup script.

**Q: Can I make warnings blocking?**  
A: Yes, set `"blocking": true` for any check in the config.

**Q: How do I update hooks?**  
A: Pull latest changes and run `./setup-hooks.sh` again.

---

## License

MIT License - Free to use and modify for your projects.

---

## Support

For issues or questions:
1. Check this README
2. Review the hook output messages (they're designed to be helpful)
3. Check `.githooks-config.json` for configuration issues
4. Review hook files in `hooks-templates/` for logic

---

**Built with ❤️ for better code quality and security**
