#!/bin/sh

# get_echo <raw_query>
get_msg() {
  raw_query="$1"
  # Extract and decode "msg" parameter
  msg=$(echo "$raw_query" | tr '&' '\n' | sed -n 's/^msg=\(.*\)/\1/p' | tr '+' ' ' | sed 's/%20/ /g')
  # Escape quotes
  msg=$(printf "%s" "$msg" | sed 's/"/\\"/g')
  printf '{"echo":"%s"}' "$msg"
}
