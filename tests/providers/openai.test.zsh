#!/usr/bin/env zsh

# Load test helper
source "${0:A:h:h}/test_helper.zsh"

# Load the openai provider
source "$PLUGIN_DIR/lib/providers/openai.zsh"

# Test check requirements
test_openai_check_requirements_with_key() {
    setup_test_env
    export OPENAI_API_KEY="test-key"
    
    openai_check_requirements >/dev/null 2>&1
    local result=$?
    
    assert_equals "$result" "0"
    teardown_test_env
}

test_openai_check_requirements_without_key() {
    setup_test_env
    unset OPENAI_API_KEY
    
    local output
    output=$(openai_check_requirements 2>&1)
    local result=$?
    
    assert_equals "$result" "1"
    assert_contains "$output" "OPENAI_API_KEY is not set"
    teardown_test_env
}

test_openai_generate_commit_message_success() {
    setup_test_env
    export OPENAI_API_KEY="test-key"
    
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
        "choices": [
            {
                "message": {
                    "content": "feat: update greeting message\n\nChanged greeting from \"Hello World\" to \"Hello AI World\""
                }
            }
        ]
    }'
    
    local output
    output=$(openai_generate_commit_message "$diff_output" "On branch main" 2>&1)
    local result=$?
    
    assert_equals "$result" "0"
    assert_contains "$output" "feat: update greeting message"
    
    teardown_test_env
}

test_openai_generate_commit_message_api_error() {
    setup_test_env
    export OPENAI_API_KEY="test-key"
    
    # Define diff output
    local diff_output="some changes"
    
    # Mock error response
    mock_curl_response '{
        "error": {
            "message": "Invalid API key"
        }
    }' 0
    
    local output
    output=$(openai_generate_commit_message "$diff_output" "On branch main" 2>&1)
    local result=$?
    
    assert_equals "$result" "1"
    assert_contains "$output" "Failed to generate commit message"
    
    teardown_test_env
}

test_openai_generate_commit_message_no_changes() {
    setup_test_env
    export OPENAI_API_KEY="test-key"
    
    # Define empty diff output
    local diff_output=""
    
    local output
    output=$(openai_generate_commit_message "$diff_output" "On branch main" 2>&1)
    local result=$?
    
    assert_equals "$result" "1"
    assert_contains "$output" "Failed to generate commit message"
    
    teardown_test_env
}

# Run tests
echo "Testing OpenAI provider..."
test_openai_check_requirements_with_key
test_openai_check_requirements_without_key
test_openai_generate_commit_message_success
test_openai_generate_commit_message_api_error
test_openai_generate_commit_message_no_changes