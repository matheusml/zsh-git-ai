#!/usr/bin/env zsh

# Load test helper
source "${0:A:h:h}/test_helper.zsh"

# Load the ollama provider
source "$PLUGIN_DIR/lib/providers/ollama.zsh"

# Test check requirements
test_ollama_check_requirements_success() {
    setup_test_env
    
    # Mock curl to simulate ollama being available
    mock_command "curl" "" 0
    
    ollama_check_requirements >/dev/null 2>&1
    local result=$?
    
    assert_equals "$result" "0"
    teardown_test_env
}

test_ollama_check_requirements_not_running() {
    setup_test_env
    
    # Mock curl to simulate ollama not being available
    mock_command "curl" "" 7  # Connection refused
    
    local output
    output=$(ollama_check_requirements 2>&1)
    local result=$?
    
    assert_equals "$result" "1"
    assert_contains "$output" "Cannot connect to Ollama"
    teardown_test_env
}

test_ollama_generate_commit_message_success() {
    setup_test_env
    
    # Define diff output
    local diff_output="diff --git a/test.txt b/test.txt
index 1234567..abcdefg 100644
--- a/test.txt
+++ b/test.txt
@@ -1 +1 @@
-Hello World
+Hello AI World"
    
    # Mock jq availability
    mock_jq true
    
    # Mock successful curl response
    mock_curl_response '{
        "response": "feat: update greeting message\n\nChanged greeting from \"Hello World\" to \"Hello AI World\""
    }'
    
    local output
    output=$(ollama_generate_commit_message "$diff_output" "On branch main" 2>&1)
    local result=$?
    
    assert_equals "$result" "0"
    assert_contains "$output" "feat: update greeting message"
    
    teardown_test_env
}

test_ollama_generate_commit_message_api_error() {
    setup_test_env
    
    # Define diff output
    local diff_output="some changes"
    
    # Mock error response
    mock_curl_response '{
        "error": "Model not found"
    }' 0
    
    local output
    output=$(ollama_generate_commit_message "$diff_output" "On branch main" 2>&1)
    local result=$?
    
    assert_equals "$result" "1"
    assert_contains "$output" "Failed to generate commit message"
    
    teardown_test_env
}

test_ollama_generate_commit_message_no_changes() {
    setup_test_env
    
    # Define empty diff output
    local diff_output=""
    
    local output
    output=$(ollama_generate_commit_message "$diff_output" "On branch main" 2>&1)
    local result=$?
    
    assert_equals "$result" "1"
    assert_contains "$output" "Failed to generate commit message"
    
    teardown_test_env
}

test_ollama_custom_model() {
    setup_test_env
    export ZSH_GIT_AI_OLLAMA_MODEL="codellama"
    
    # Verify model is set correctly
    source "$PLUGIN_DIR/lib/providers/ollama.zsh"
    assert_equals "$ZSH_GIT_AI_OLLAMA_MODEL" "codellama"
    
    teardown_test_env
}

# Run tests
echo "Testing Ollama provider..."
test_ollama_check_requirements_success
test_ollama_check_requirements_not_running
test_ollama_generate_commit_message_success
test_ollama_generate_commit_message_api_error
test_ollama_generate_commit_message_no_changes
test_ollama_custom_model