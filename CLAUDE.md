# Project Development Guide for git-commit-ai

## Overview
This is a lightweight ZSH tool that generates git commit messages using various AI providers (Anthropic, OpenAI, Gemini, Ollama). The codebase is pure shell script with zero runtime dependencies.

## Testing

### Running Tests
```bash
# Run all tests
./run-tests.zsh

# Run specific test directory
./run-tests.zsh tests/providers

# Run single test file
zsh tests/providers/anthropic.test.zsh
```

### Test Structure
- Tests are located in `tests/` directory
- Provider-specific tests in `tests/providers/`
- Test helper utilities in `tests/test_helper.zsh`
- Custom ZSH-based testing framework with mocking support

### Writing Tests
- Follow existing test patterns in test files
- Use `test_helper.zsh` functions for assertions and mocking
- Each test should have proper setup/teardown
- Mock external commands (curl, jq) rather than making real API calls

## Development Workflow

### Before Committing
1. Run all tests: `./run-tests.zsh`
2. Verify shellcheck passes (runs automatically in CI)
3. Test your changes manually with different providers
4. Ensure no API keys or sensitive data are committed

### Code Style
- Follow existing ZSH scripting patterns
- Use meaningful variable names with proper scoping
- Add error handling for all external commands
- Keep functions small and focused
- Maintain backwards compatibility with older ZSH versions

### Provider Implementation
When adding/modifying AI providers:
1. Implement provider in `lib/providers/` directory
2. Add comprehensive tests in `tests/providers/`
3. Update documentation if adding new configuration options
4. Test with actual API calls (use your own keys)
5. Ensure provider follows the standard interface:
   - `{provider}_check_requirements` function
   - `{provider}_generate_commit_message` function accepting diff and status

### Common Tasks
- **Adding a new provider**: Copy existing provider pattern, add tests
- **Modifying commit generation**: Update provider logic and test with various diff formats
- **Changing main script logic**: Update `zsh-git-ai.zsh` and test in `tests/main.test.zsh`

### Important Notes
- This is a shell-only project - no Node.js, Python, or other runtimes
- Keep the codebase lightweight
- Preserve zero-dependency philosophy (jq is optional)
- CI runs on every PR - ensure tests pass before merging
- All providers should gracefully handle missing jq by falling back to sed/grep

