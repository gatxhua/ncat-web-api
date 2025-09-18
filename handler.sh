#!/bin/sh

# Helper: get_param_value <raw_query> <key>
get_param_value() {
  echo "$1" | tr '&' '\n' | sed -n "s/^$2=\(.*\)/\1/p" | tr '+' ' ' | sed 's/%20/ /g'
}

# Helper: is_key_exist <raw_query> <key>
is_key_exist() {
  echo "$1" | tr '&' '\n' | grep -q "^$2="
}

# Read HTTP request line
read request_line

# Parse method and full path
method=$(printf "%s" "$request_line" | cut -d' ' -f1)
full_path=$(printf "%s" "$request_line" | cut -d' ' -f2)

# Extract endpoint and raw query
path=${full_path%%\?*}
endpoint=${path#/}        # e.g., cpu, mem, echo
raw_query=${full_path#*\?}
[ "$raw_query" = "$full_path" ] && raw_query=""

# Default response values
status="200 OK"
body=""

# Only GET supported
if [ "$method" != "GET" ]; then
  status="400 Bad Request"
  body='{"error":"only GET supported"}'
else
  # Path-based dynamic handler
  script_dir=$(dirname "$0")/api
  script_file="$script_dir/get_${endpoint}.sh"
  func_name="get_${endpoint}"

  if [ -f "$script_file" ]; then
    # Source the endpoint script
    . "$script_file"
    # Check if the function is defined
    if command -v "$func_name" >/dev/null 2>&1; then
      # Call the function with raw query
      body=$("$func_name" "$raw_query")
    else
      status="500 Internal Server Error"
      body='{"error":"handler function not found"}'
    fi
  else
    status="404 Not Found"
    body='{"error":"endpoint not found"}'
  fi
fi

# Send HTTP response
length=$(printf "%s" "$body" | wc -c)
printf "HTTP/1.1 %s\r\nContent-Type: application/json\r\nContent-Length: %d\r\n\r\n%s" \
  "$status" "$length" "$body"
