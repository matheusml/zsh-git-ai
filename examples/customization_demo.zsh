#!/usr/bin/env zsh

# Example: Demonstrating commit message customization options

echo "=== Git Commit AI - Customization Examples ==="
echo ""

# Example 1: Default (simple) style
echo "1. Default style (simple):"
echo "   export ZSH_GIT_AI_STYLE=\"simple\"  # or unset"
echo "   Result: \"Add user authentication feature\""
echo ""

# Example 2: Conventional commits
echo "2. Conventional Commits style:"
echo "   export ZSH_GIT_AI_STYLE=\"conventional\""
echo "   Result: \"feat(auth): add user authentication\""
echo ""

# Example 3: Semantic style
echo "3. Semantic style:"
echo "   export ZSH_GIT_AI_STYLE=\"semantic\""
echo "   Result: \"Add user authentication with JWT support\""
echo ""

# Example 4: Custom length
echo "4. Custom message length:"
echo "   export ZSH_GIT_AI_MAX_LENGTH=\"100\""
echo "   Result: Allows longer, more descriptive commit messages"
echo ""

# Example 5: Fully custom prompt
echo "5. Custom prompt:"
echo "   export ZSH_GIT_AI_PROMPT=\"Write a commit message as a haiku:\""
echo "   Result: "
echo "      Code flows like water"
echo "      Authentication added"  
echo "      Users now secure"
echo ""

echo "To use these, add the exports to your ~/.zshrc file!"