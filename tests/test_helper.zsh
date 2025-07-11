#!/usr/bin/env zsh
# Test helper utilities for git-commit-ai tests

# Source the plugin files
export ZSH_GIT_AI_TEST_MODE=1
PLUGIN_DIR="${0:A:h:h}"

# Mock functions storage
typeset -gA MOCKED_COMMANDS
typeset -gA MOCK_OUTPUTS
typeset -gA MOCK_EXIT_CODES
typeset -gA CALL_COUNTS

# Initialize mock for a command
mock_command() {
    local cmd="$1"
    local output="${2:-}"
    local exit_code="${3:-0}"
    
    MOCKED_COMMANDS[$cmd]=1
    MOCK_OUTPUTS[$cmd]="$output"
    MOCK_EXIT_CODES[$cmd]="$exit_code"
    CALL_COUNTS[$cmd]=0
    
    # Create function to override command
    eval "
    $cmd() {
        CALL_COUNTS[$cmd]=\$((CALL_COUNTS[$cmd] + 1))
        if [[ -n \"\${MOCK_OUTPUTS[$cmd]}\" ]]; then
            echo \"\${MOCK_OUTPUTS[$cmd]}\"
        fi
        return \${MOCK_EXIT_CODES[$cmd]}
    }
    "
}

# Restore mocked command
unmock_command() {
    local cmd="$1"
    unset "MOCKED_COMMANDS[$cmd]"
    unset "MOCK_OUTPUTS[$cmd]"
    unset "MOCK_EXIT_CODES[$cmd]"
    unset "CALL_COUNTS[$cmd]"
    unfunction "$cmd" 2>/dev/null
}

# Reset all mocks
reset_mocks() {
    for cmd in ${(k)MOCKED_COMMANDS}; do
        unmock_command "$cmd"
    done
}

# Assert command was called
assert_called() {
    local cmd="$1"
    local expected_times="${2:-1}"
    local actual_times="${CALL_COUNTS[$cmd]:-0}"
    
    if [[ $actual_times -ne $expected_times ]]; then
        echo "✗ Expected $cmd to be called $expected_times times, but was called $actual_times times"
        return 1
    fi
    echo "✓ $cmd was called $expected_times times"
}

# Mock curl for API requests
mock_curl_response() {
    local response="$1"
    local exit_code="${2:-0}"
    
    # Store response and exit code in global variables
    MOCK_CURL_RESPONSE="$response"
    MOCK_CURL_EXIT_CODE="$exit_code"
    
    # Create a global curl function
    function curl() {
        if [[ "$MOCK_CURL_EXIT_CODE" -ne 0 ]]; then
            return "$MOCK_CURL_EXIT_CODE"
        fi
        echo "$MOCK_CURL_RESPONSE"
        return 0
    }
}

# Mock jq command
mock_jq() {
    local available="${1:-true}"
    if [[ "$available" == "true" ]]; then
        # Mock command -v jq to return success
        command() {
            if [[ "$1" == "-v" ]] && [[ "$2" == "jq" ]]; then
                echo "/usr/bin/jq"
                return 0
            fi
            builtin command "$@"
        }
        # Also mock jq itself to parse JSON properly
        jq() {
            local args="$@"
            local input=$(cat)
            # Handle -r flag
            local raw_output=false
            if [[ "$args" == *"-r"* ]]; then
                raw_output=true
                args="${args//-r/}"
            fi
            
            # Parse based on the jq query
            local result=""
            if [[ "$args" == *".content[0].text"* ]]; then
                # For Anthropic responses
                result=$(echo "$input" | perl -0777 -ne 'if (/"text":\s*"([^"\\]*(\\.[^"\\]*)*)"/) { $val = $1; $val =~ s/\\n/\n/g; $val =~ s/\\"/"/g; print $val; }')
            elif [[ "$args" == *".error.message"* ]]; then
                # For error responses
                result=$(echo "$input" | sed -n 's/.*"message":"\([^"]*\(\\.[^"]*\)*\)".*/\1/p' | sed 's/\\"/"/g')
            elif [[ "$args" == *".choices[0].message.content"* ]]; then
                # For OpenAI responses
                result=$(echo "$input" | perl -0777 -ne 'if (/"content":\s*"([^"\\]*(\\.[^"\\]*)*)"/) { $val = $1; $val =~ s/\\n/\n/g; $val =~ s/\\"/"/g; print $val; }')
            elif [[ "$args" == *".candidates[0].content.parts[0].text"* ]]; then
                # For Gemini responses
                result=$(echo "$input" | perl -0777 -ne 'if (/"text":\s*"([^"\\]*(\\.[^"\\]*)*)"/) { $val = $1; $val =~ s/\\n/\n/g; $val =~ s/\\"/"/g; print $val; }')
            elif [[ "$args" == *".response"* ]]; then
                # For Ollama responses
                result=$(echo "$input" | perl -0777 -ne 'if (/"response":\s*"([^"\\]*(\\.[^"\\]*)*)"/) { $val = $1; $val =~ s/\\n/\n/g; $val =~ s/\\"/"/g; print $val; }')
            fi
            
            # Return result or empty based on // empty handling
            if [[ -n "$result" ]]; then
                echo "$result"
            elif [[ "$args" == *"// empty"* ]]; then
                # jq returns nothing for empty
                return 0
            else
                return 1
            fi
        }
    else
        command() {
            if [[ "$1" == "-v" ]] && [[ "$2" == "jq" ]]; then
                return 1
            fi
            builtin command "$@"
        }
    fi
}

# Mock git commands
mock_git_diff() {
    local diff_output="${1:-}"
    git() {
        if [[ "$1" == "diff" ]]; then
            shift
            echo "$diff_output"
            return 0
        fi
        builtin command git "$@"
    }
}

mock_git_status() {
    local status_output="${1:-}"
    git() {
        if [[ "$1" == "status" ]]; then
            shift
            echo "$status_output"
            return 0
        fi
        builtin command git "$@"
    }
}

# Setup test environment
setup_test_env() {
    # Set test environment variables
    export ZSH_GIT_AI_PROVIDER=""
    export ANTHROPIC_API_KEY=""
    export OPENAI_API_KEY=""
    export GEMINI_API_KEY=""
    export ZSH_GIT_AI_MODEL=""
    
    # Reset mocks
    reset_mocks
}

# Teardown test environment
teardown_test_env() {
    reset_mocks
    # Unfunction any mocked commands
    unfunction command 2>/dev/null
    unfunction jq 2>/dev/null
    unfunction curl 2>/dev/null
    unfunction git 2>/dev/null
    unset ZSH_GIT_AI_PROVIDER
    unset ANTHROPIC_API_KEY
    unset OPENAI_API_KEY
    unset GEMINI_API_KEY
    unset ZSH_GIT_AI_MODEL
    unset ZSH_GIT_AI_TEST_MODE
}

# Assert string contains
assert_contains() {
    local haystack="$1"
    local needle="$2"
    if [[ ! "$haystack" == *"$needle"* ]]; then
        echo "✗ Expected '$haystack' to contain '$needle'"
        return 1
    fi
    echo "✓ String contains expected value"
}

# Assert string equals
assert_equals() {
    local actual="$1"
    local expected="$2"
    if [[ "$actual" != "$expected" ]]; then
        echo "✗ Expected '$expected' but got '$actual'"
        return 1
    fi
    echo "✓ Values are equal"
}

# Assert string does not contain
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✗ Expected '$haystack' to not contain '$needle'"
        return 1
    fi
    echo "✓ String does not contain value"
}

# Assert greater than
assert_greater_than() {
    local actual="$1"
    local expected="$2"
    if [[ "$actual" -le "$expected" ]]; then
        echo "✗ Expected '$actual' to be greater than '$expected'"
        return 1
    fi
    echo "✓ Value is greater than expected"
}

# Capture function output
capture_output() {
    local func="$1"
    shift
    local output
    output=$("$func" "$@" 2>&1)
    echo "$output"
}

# Create temporary test directory
create_test_dir() {
    local test_dir=$(mktemp -d)
    echo "$test_dir"
}

# Cleanup temporary test directory
cleanup_test_dir() {
    local test_dir="$1"
    [[ -d "$test_dir" ]] && rm -rf "$test_dir"
}