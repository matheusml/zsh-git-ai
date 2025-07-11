#!/usr/bin/env zsh

# Load test helper
source "${0:A:h}/test_helper.zsh"

# Test main script functionality
test_default_provider() {
    setup_test_env
    unset ZSH_GIT_AI_PROVIDER
    source "$PLUGIN_DIR/zsh-git-ai.plugin.zsh" 2>/dev/null || true
    # Default should be anthropic
    assert_equals "$ZSH_GIT_AI_PROVIDER" "anthropic"
    teardown_test_env
}

test_load_provider_success() {
    setup_test_env
    export ZSH_GIT_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock the provider check requirements function
    anthropic_check_requirements() {
        return 0
    }
    
    # Source just the load_provider function
    source "$PLUGIN_DIR/zsh-git-ai.plugin.zsh" 2>/dev/null || true
    local result
    load_provider "anthropic" >/dev/null 2>&1
    result=$?
    
    assert_equals "$result" "0"
    teardown_test_env
}

test_load_provider_invalid() {
    setup_test_env
    export ZSH_GIT_AI_PROVIDER="invalid_provider"
    
    # Source just the load_provider function
    source "$PLUGIN_DIR/zsh-git-ai.plugin.zsh" 2>/dev/null || true
    local output
    output=$(load_provider "invalid_provider" 2>&1)
    local result=$?
    
    assert_equals "$result" "1"
    assert_contains "$output" "Provider 'invalid_provider' not found"
    teardown_test_env
}

test_spinner_function_exists() {
    setup_test_env
    source "$PLUGIN_DIR/zsh-git-ai.plugin.zsh" 2>/dev/null || true
    
    # Check if show_spinner function is defined
    if type show_spinner >/dev/null 2>&1; then
        echo "✓ show_spinner function exists"
    else
        echo "✗ show_spinner function not found"
        return 1
    fi
    
    teardown_test_env
}

# Run tests
echo "Testing main script..."
test_default_provider
test_load_provider_success
test_load_provider_invalid
test_spinner_function_exists