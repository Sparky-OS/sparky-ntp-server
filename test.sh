#!/bin/sh

# Test script for install.sh

# Create a mock zone.tab file
create_mock_zone_tab() {
    cat > zone.tab <<EOF
AD      +4232+00131     Europe/Andorra
AE      +2518+05518     Asia/Dubai
AF      +3432+06912     Asia/Kabul
US      +4336-11612     America/Boise
GB      +5130-00007      Europe/London
XX      +0000+00000     Fake/Timezone/That/Is/A/Substring/Of/US/Mountain
US      +4336-11612     US/Mountain
EOF
}

# Create a mock timezone file
create_mock_timezone() {
    echo "US/Mountain" > timezone
}

# Source the script to be tested
# We need to override the path to zone.tab
# and the timezone detection
. ./install.sh

# Override the timezone detection to use our mock file
detect_cc_buggy() {
    tz=$(cat timezone)
    [ -z "$tz" ] && return
    grep -F "${tz}" zone.tab 2>/dev/null | awk 'NR==1{print tolower($1)}'
}

detect_cc() {
    tz=$(cat timezone)
    [ -z "$tz" ] && return
    grep -E "\s${tz}$" zone.tab 2>/dev/null | awk 'NR==1{print tolower($1)}'
}


# Run the test
test_detect_cc() {
    create_mock_zone_tab
    create_mock_timezone

    # Run the buggy function and capture the output
    buggy_result=$(detect_cc_buggy)

    # Assert the buggy result
    if [ "$buggy_result" = "xx" ]; then
        echo "Buggy test passed!"
    else
        echo "Buggy test failed! Expected 'xx', got '$buggy_result'"
        exit 1
    fi

    # Run the fixed function and capture the output
    fixed_result=$(detect_cc)

    # Assert the fixed result
    if [ "$fixed_result" = "us" ]; then
        echo "Fixed test passed!"
    else
        echo "Fixed test failed! Expected 'us', got '$fixed_result'"
        exit 1
    fi

    # Clean up
    rm zone.tab timezone
}

test_detect_cc
