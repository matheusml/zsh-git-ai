# Contributing to zsh-git-ai

Thanks for wanting to help! We love contributions from everyone. 💙

## Quick Start

1. Fork & clone the repo
2. Make your changes
3. Test your changes (see Testing section below)
4. Submit a pull request

That's it! We'll help you with the rest.

## Development

```bash
# Try out your changes
source zsh-git-ai.zsh

# Test with a real commit
git add some-file
git commit
```

## What We're Looking For

- 🐛 **Bug fixes** - Found something broken? Fix it!
- ✨ **New features** - Have an idea? Let's discuss it first (open an issue)
- 📝 **Documentation** - Help others understand the project
- 🧪 **Tests** - More tests = more confidence

## Code Style

Just follow the existing style you see in the codebase. When in doubt:
- Use meaningful names
- Keep functions small
- Add comments for tricky parts
- Follow shell scripting best practices

## Testing

### Manual Testing

To test your changes:

```bash
# 1. Source the plugin
source zsh-git-ai.zsh

# 2. Create some test changes
echo "test" > test.txt
git add test.txt

# 3. Test the commit flow
git commit

# 4. Test edge cases
# - Empty diff
# - Large diffs
# - Binary files
# - Multiple file changes
```

### Test Scenarios

Make sure to test these scenarios:
- ✅ Normal commit with single file
- ✅ Commit with multiple files
- ✅ Large diffs (100+ lines)
- ✅ Cancel operation
- ✅ Edit operation
- ✅ Regenerate operation
- ✅ No staged changes
- ✅ API errors handling

## Submitting PRs

### Before Submitting

1. **Test thoroughly** - Run through all the test scenarios
2. **Update docs** - If you changed behavior, update the README
3. **Keep it simple** - We value simplicity and maintainability

### PR Guidelines

- Use clear, descriptive titles
- Explain what and why in the description
- Reference any related issues
- Include screenshots for UI changes

### Commit Messages

Follow conventional commits:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Formatting changes
- `refactor:` Code restructuring
- `test:` Test additions/changes
- `chore:` Maintenance tasks

Example:
```
feat: add support for custom commit message templates

- Allow users to define templates in config
- Add template variables for common patterns
- Update documentation with examples
```

## Development Tips

### Debugging

Add debug output:
```bash
# Add this for debugging
echo "Debug: $variable" >&2
```

### API Testing

Test API responses:
```bash
# Test the Claude API directly
curl -X POST "https://api.anthropic.com/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 100,
    "messages": [{
      "role": "user",
      "content": "Generate a commit message for: Added new feature"
    }]
  }'
```

## Getting Help

- 💬 Open an issue for questions
- 🔍 Check existing issues first
- 📖 Read the documentation
- 🤝 Be patient and respectful

## Code of Conduct

- Be welcoming and inclusive
- Respect different viewpoints
- Accept constructive criticism
- Focus on what's best for the community

## Recognition

Contributors will be recognized in:
- The project README
- Release notes
- Our hearts ❤️

---

Thank you for contributing to zsh-git-ai! Your efforts help make git commits better for everyone.