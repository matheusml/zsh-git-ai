#!/usr/bin/env zsh

# Source test helper
source "${0:A:h}/../test_helper.zsh"

# Source the prompt builder directly
source "${0:A:h}/../../lib/prompt_builder.zsh"

# Test that prompt builder is used with custom style
test_prompt_builder_custom_style() {
    export ZSH_GIT_AI_STYLE="conventional"
    unset ZSH_GIT_AI_PROMPT
    
    local result=$(build_commit_prompt "test diff" "test status")
    
    assert_contains "$result" "Conventional Commits"
    assert_contains "$result" "feat, fix, docs"
}

# Test that prompt builder is used with custom prompt
test_prompt_builder_custom_prompt() {
    export ZSH_GIT_AI_PROMPT="My custom prompt template"
    
    local result=$(build_commit_prompt "test diff" "test status")
    
    assert_contains "$result" "My custom prompt template"
    assert_contains "$result" "test status"
}

# Run tests
test_prompt_builder_custom_style
test_prompt_builder_custom_prompt

echo "All customization tests passed!"