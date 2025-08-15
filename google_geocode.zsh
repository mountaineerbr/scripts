#!/usr/bin/env zsh
# v0.1.3  aug/2025  by mountaineerbr
# google_geocode.zsh - Simple Google Geocoding API wrapper.
# Usage:
#   export GOOGLE_API_KEY="YOUR_API_KEY"
#
#   Geocoding (address -> lat,lng):
#   google_geocode.zsh "1600 Amphitheatre Pkwy, Mountain View, CA"
#
#   Reverse Geocoding (lat,lng -> address):
#   google_geocode.zsh 40.714224,-73.961452
#https://developers.google.com/maps/documentation/geocoding/overview

set -o pipefail

# --- Configuration ---
GEOCODE_API_URL="https://maps.googleapis.com/maps/api/geocode/json";

# extract a component's long name by type.
JQ_FUNC='def get_component($type): (.address_components[]? | select(.types[]? == $type) | .long_name) // "";';

# extract an address component's long_name.
JQ_FUNC='
  def get_component(type):
    first(.address_components[]? | select(.types[]? == type) | .long_name) // "";
';


urlencode () {
  jq --slurp --raw-input --raw-output @uri <<<$*;
}


# --- Pre-flight Checks ---
if [[ -z "${GOOGLE_API_KEY:-}" ]]; then
  print -u2 "Error: GOOGLE_API_KEY environment variable is not set."
  exit 1
fi

if (( $# == 0 )); then
  print -u2 "Usage: ${0##*/} <address | lat,lng>"
  exit 1
fi

# --- Main Logic ---
if [[ "$*" != *[!$IFS0-9,-]* ]]; then
  # Reverse Geocoding
  latlng="${*}" latlng="${latlng##[ ,]}" latlng="${latlng%%[ ,]}"
  latlng="${latlng// /,}" latlng="${latlng//,,/,}"
  response=$(curl -sL "${GEOCODE_API_URL}?latlng=${latlng}&key=${GOOGLE_API_KEY}")
  if ((!${#response})) || [[ ${response:0:2048} = *'"error_message"'* ]]
  then
    print -r -- "${response:-err}" >&2;
    exit 2;
  fi;

  jq -r "${JQ_FUNC} .results[] | [
      .formatted_address,
      get_component(\"country\"),
      get_component(\"administrative_area_level_1\"),
      get_component(\"locality\"),
      (.geometry.location | \"\(.lat),\(.lng)\")
    ] | @tsv" <<< $response;
else
  # Geocoding
  address="$*"
  encoded_address=$(urlencode "$address")
  response=$(curl -sL "${GEOCODE_API_URL}?address=${encoded_address}&key=${GOOGLE_API_KEY}")
  if ((!${#response})) || [[ ${response:0:2048} = *'"error_message"'* ]]
  then
    print -r -- "${response:-err}" >&2;
    exit 2;
  fi;

  jq -r "${JQ_FUNC} .results[] | [
      (.geometry.location | \"\(.lat),\(.lng)\"),
      get_component(\"country\"),
      get_component(\"administrative_area_level_1\"),
      get_component(\"locality\"),
      .formatted_address
    ] | @tsv" <<< $response;
fi || ! print -r -- "${response:-err}" >&2;

