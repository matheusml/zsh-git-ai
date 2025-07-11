#!/usr/bin/env zsh

# Source test helper
source "${0:A:h}/test_helper.zsh"

# Source the prompt builder
source "${0:A:h}/../lib/prompt_builder.zsh"

# Test simple style (default)
test_simple_style() {
    local diff="test diff"
    local test_status="test status"
    unset ZSH_GIT_AI_PROMPT
    unset ZSH_GIT_AI_STYLE
    unset ZSH_GIT_AI_MAX_LENGTH
    
    local result=$(build_commit_prompt "$diff" "$test_status")
    
    assert_contains "$result" "imperative mood"
    assert_contains "$result" "72 characters"
    assert_contains "$result" "Git status:"
    assert_contains "$result" "test status"
    assert_contains "$result" "Git diff:"
    assert_contains "$result" "test diff"
}

# Test conventional commits style
test_conventional_style() {
    local diff="test diff"
    local test_status="test status"
    unset ZSH_GIT_AI_PROMPT
    export ZSH_GIT_AI_STYLE="conventional"
    export ZSH_GIT_AI_MAX_LENGTH="100"
    
    local result=$(build_commit_prompt "$diff" "$test_status")
    
    assert_contains "$result" "Conventional Commits"
    assert_contains "$result" "<type>(<scope>): <subject>"
    assert_contains "$result" "100 characters"
    assert_contains "$result" "feat, fix, docs"
}

# Test semantic style
test_semantic_style() {
    local diff="test diff"
    local test_status="test status"
    unset ZSH_GIT_AI_PROMPT
    export ZSH_GIT_AI_STYLE="semantic"
    export ZSH_GIT_AI_MAX_LENGTH="50"
    
    local result=$(build_commit_prompt "$diff" "$test_status")
    
    assert_contains "$result" "semantic prefix"
    assert_contains "$result" "Add, Update, Fix, Remove"
    assert_contains "$result" "50 characters"
}

# Test custom prompt
test_custom_prompt() {
    local diff="test diff"
    local test_status="test status"
    export ZSH_GIT_AI_PROMPT="Custom prompt for testing"
    export ZSH_GIT_AI_STYLE="conventional"  # Should be ignored
    
    local result=$(build_commit_prompt "$diff" "$test_status")
    
    assert_contains "$result" "Custom prompt for testing"
    assert_contains "$result" "Git status:"
    assert_contains "$result" "test status"
    assert_not_contains "$result" "Conventional Commits"
}

# Run tests
test_simple_style
test_conventional_style
test_semantic_style
test_custom_prompt

echo "All prompt builder tests passed!"