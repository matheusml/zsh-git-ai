# Git Commit AI

A minimal ZSH plugin that generates AI-powered commit messages using Claude.

## Setup

1. Set your Claude API key:
```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

2. Source the plugin in your `.zshrc`:
```bash
source ~/Apps/git-commit-ai/git-commit-ai.zsh
```

3. Reload your shell:
```bash
source ~/.zshrc
```

## Usage

Simply run `git commit` (without the `-m` flag) when you have staged changes:

```bash
git add .
git commit
```

The plugin will:
1. Show a loading spinner while generating a commit message
2. Display the generated message
3. Give you options to:
   - **[A]ccept** - Use the generated message as-is
   - **[E]dit** - Open the message in your editor for modifications
   - **[R]egenerate** - Generate a new message
   - **[C]ancel** - Cancel the commit

## Testing

To test the plugin:

```bash
# Create a test file
echo "test content" > test.txt
git add test.txt
git commit
```

## Notes

- The plugin only intercepts `git commit` when called without the `-m` flag
- All other git commands work normally
- Requires staged changes to generate a commit message