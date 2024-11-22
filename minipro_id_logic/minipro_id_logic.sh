#!/bin/bash
# Minipro IC Identifier
#
# A command-line tool designed to identify logic ICs using MiniPro compatible programmers.
#
# Copyright (c) 2024, Gregory Strike
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


# Default values
DEBUG=false
PINS=""
VERSION="0.1" # Version of the script

echo "Minipro IC Identifier v$VERSION"
echo "Licensed under the MIT License - (c)2024 Gregory Strike"
echo

# Path to the logicic.xml file
LOGIC_IC_DB="/usr/local/share/minipro/logicic.xml"

# Function to display usage
usage() {
  echo "Usage: $0 --pins X [--debug]"
  echo "  --pins X      Specify the number of pins on the chip (required)"
  echo "  --debug       Enable debug mode to output all stdout and stderr"
  exit 1
}

# Check if xmllint is installed
if ! command -v xmllint &> /dev/null; then
  echo "Error: xmllint is not installed. Please install it and try again."
  exit 1
fi

# Check if minipro is installed
if ! command -v minipro &> /dev/null; then
  echo "Error: minipro is not installed. Please install it and try again."
  exit 1
fi

# Check if logicic.xml exists
if [[ ! -f "$LOGIC_IC_DB" ]]; then
  echo "Error: logicic.xml not found at $LOGIC_IC_DB."
  exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pins)
      PINS="$2"
      shift 2
      ;;
    --debug)
      DEBUG=true
      shift
      ;;
    *)
      usage
      ;;
  esac
done

# Validate required arguments
if [[ -z "$PINS" ]]; then
  echo "Error: --pins is required."
  usage
fi

# Function to extract ICs with a specific number of pins
extract_ics_with_pins() {
  local pin_count=$1
  xmllint --xpath "//ic[@pins='$pin_count'][@name]" "$LOGIC_IC_DB" 2>/dev/null
}

test_chip() {
  local ic_name=$1
  local percentage=$2
  
  if $DEBUG; then
    # Debug mode: Run minipro with detailed output
    echo "Testing chip: $ic_name"
    minipro -p "$ic_name" -T
    return $?
  else
    # Non-debug mode: Show percentage while testing
    OUTPUT=$(minipro -p "$ic_name" -T 2>/dev/null) &
    local pid=$!
    
    # Show percentage until the test is complete
    while kill -0 "$pid" 2>/dev/null; do
      printf "\rTesting chips [%3d%%]" "$percentage"
    done
    wait "$pid"
    local exit_code=$?
    
    # Clear percentage line after testing
    printf "\r"
    
    # Return success or failure
    if [[ $exit_code -eq 0 ]]; then
      echo -e "\nPotential match: $ic_name"
      echo "$OUTPUT"
      return 0
    fi
  fi
  return 1
}


# Extract ICs with the specified number of pins
IC_LIST=$(extract_ics_with_pins "$PINS")

if [[ -z "$IC_LIST" ]]; then
  echo "No ICs with $PINS pins found in the database."
  exit 1
fi

# Parse and loop through each IC
echo "Testing ICs with $PINS pins:"
IC_ARRAY=($(echo "$IC_LIST" | grep -oP 'name="\K[^"]+'))
TOTAL_ICS=${#IC_ARRAY[@]}
POTENTIAL_MATCHES=()

for idx in "${!IC_ARRAY[@]}"; do
  IC_NAME="${IC_ARRAY[idx]}"
  PERCENTAGE=$(( (idx + 1) * 100 / TOTAL_ICS ))
  
  # Test the chip
  if test_chip "$IC_NAME" "$PERCENTAGE"; then
    POTENTIAL_MATCHES+=("$IC_NAME")
  fi
done

# Output results
echo
if [[ ${#POTENTIAL_MATCHES[@]} -eq 1 ]]; then
  echo "Single match found: ${POTENTIAL_MATCHES[0]}"
  exit 0
elif [[ ${#POTENTIAL_MATCHES[@]} -gt 1 ]]; then
  echo "Multiple matches found:"
  for MATCH in "${POTENTIAL_MATCHES[@]}"; do
    echo "$MATCH"
  done
else
  echo "No matching chip found."
  exit 1
fi
