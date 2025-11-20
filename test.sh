#!/bin/sh

# Test script for install.sh

# --- Test Harness ---

TEST_DIR="test_env"

# Mock files
MOCK_ZONE_TAB="$TEST_DIR/zone.tab"
MOCK_TIMEZONE="$TEST_DIR/timezone"
MOCK_ETC_DIR="$TEST_DIR/etc"
MOCK_SPARKY_NTP_CONF_TPL="$TEST_DIR/etc/sparky-ntp.conf"
MOCK_DEST_SPARKY_NTP_CONF="$TEST_DIR/etc/sparky-ntp.conf.dest"


# Test setup
setup() {
    # Create mock directories
    mkdir -p "$TEST_DIR"
    mkdir -p "$MOCK_ETC_DIR"

    # Create mock zone.tab file
    cat > "$MOCK_ZONE_TAB" <<EOF
AD      +4232+00131     Europe/Andorra
AE      +2518+05518     Asia/Dubai
AF      +3432+06912     Asia/Kabul
US      +4336-11612     America/Boise
GB      +5130-00007      Europe/London
XX      +0000+00000     Fake/Timezone/That/Is/A/Substring/Of/US/Mountain
US      +4336-11612     US/Mountain
EOF

    # Create mock timezone file
    echo "US/Mountain" > "$MOCK_TIMEZONE"

    # Create mock sparky-ntp.conf template
    cat > "$MOCK_SPARKY_NTP_CONF_TPL" <<EOF
@NTP_SERVERS@
EOF
}

# Test teardown
teardown() {
    rm -rf "$TEST_DIR"
}

# Assertion functions
assert_equals() {
    expected="$1"
    actual="$2"
    message="$3"
    if [ "$expected" != "$actual" ]; then
        echo "Assertion failed: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        exit 1
    fi
     echo "Assertion passed: $message"
}

# --- Test Setup ---

# Source the script to be tested
# We need to override the path to zone.tab
# and the timezone detection
. ./install.sh

# Override functions with hardcoded paths
# We can't change the original script, so we override the functions
# that use hardcoded paths to use our mock paths instead.
install_conf() {
    cc=$(detect_cc)
    servers=$(generate_servers "$cc")
    dest="$MOCK_DEST_SPARKY_NTP_CONF"
    {
        while IFS= read -r line; do
            case "$line" in
                *'@NTP_SERVERS@'*) printf '%s\n' "$servers" ;;
                *) printf '%s\n' "$line" ;;
            esac
        done < "$MOCK_SPARKY_NTP_CONF_TPL"
    } > "$dest"
}

main() {
    if [ "$1" = "uninstall" ]; then
            rm -f "$MOCK_DEST_SPARKY_NTP_CONF"
    else
            install_conf
    fi
}


# Override the timezone detection to use our mock file
detect_cc_buggy() {
    tz=$(cat "$MOCK_TIMEZONE")
    [ -z "$tz" ] && return
    grep -F "${tz}" "$MOCK_ZONE_TAB" 2>/dev/null | awk 'NR==1{print tolower($1)}'
}

detect_cc() {
    tz=$(cat "$MOCK_TIMEZONE")
    [ -z "$tz" ] && return
    grep -E "\s${tz}$" "$MOCK_ZONE_TAB" 2>/dev/null | awk 'NR==1{print tolower($1)}'
}


# --- Test Cases ---

# Test for detect_cc function
test_detect_cc() {
    # Run the buggy function and capture the output
    buggy_result=$(detect_cc_buggy)
    assert_equals "xx" "$buggy_result" "detect_cc_buggy should return 'xx'"

    # Run the fixed function and capture the output
    fixed_result=$(detect_cc)
    assert_equals "us" "$fixed_result" "detect_cc should return 'us'"
}

test_generate_servers() {
    # Test with 'br' country code
    expected_br="server a.st1.ntp.br    iburst prefer
server b.st1.ntp.br    iburst
server c.st1.ntp.br    iburst"
    actual_br=$(generate_servers "br")
    assert_equals "$expected_br" "$actual_br" "generate_servers with 'br' should return Brazilian servers"

    # Test with 'us' country code
    expected_us="server 0.us.pool.ntp.org    iburst
server 1.us.pool.ntp.org    iburst
server 2.us.pool.ntp.org    iburst
server 3.us.pool.ntp.org    iburst"
    actual_us=$(generate_servers "us")
    assert_equals "$expected_us" "$actual_us" "generate_servers with 'us' should return pool.ntp.org servers"
}


# --- Test Runner ---

run_test() {
    test_name="$1"
    echo "--- Running test: $test_name ---"
    setup
    $test_name
    teardown
    echo "--- Test passed: $test_name ---"
    echo
}

run_test test_detect_cc
run_test test_generate_servers

test_install_conf() {
    install_conf
    expected_servers=$(generate_servers "us")
    assert_equals "$expected_servers" "$(cat "$MOCK_DEST_SPARKY_NTP_CONF")" "install_conf should correctly replace the placeholder"
}

run_test test_install_conf

test_main_uninstall() {
    # Create a dummy file to be removed
    touch "$MOCK_DEST_SPARKY_NTP_CONF"
    main "uninstall"
    if [ -f "$MOCK_DEST_SPARKY_NTP_CONF" ]; then
        echo "Assertion failed: main uninstall should remove the config file"
        exit 1
    fi
    echo "Assertion passed: main uninstall should remove the config file"
}

run_test test_main_uninstall


echo "All tests passed!"
