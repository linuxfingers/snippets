#!/bin/bash

#################################################################################
#										#
# Title: 	S2 Ingestion Script						#
# Author: 	Eva Gamma Mead							#
# Date: 	2025-08-21							#
#										#
# Purpose: 	Creates an ingestible CSV from a lean list for a LenelS2	#
# 		System that uses a HID Corporate 1000 credential format.	#
#										#
# ###############################################################################
#										#
# Lean List Example:								#
# 										#
# 	LASTNAME,FIRSTNAME,PORTALS,NUMBER,EMAIL					#
# 	Langley,Richard,IT;Server,101337,langley@thelonegunman.info             #
#										#
# LASTNAME	Employee's full last name					#
# FIRSTNAME	Employee'd full first name					#
# PORTALS 	Shorthand access levels - see ACCESS_MAP for details		#
# NUMBER	HID number provided by Security Office				#
# EMAIL		Employee's email address					#
#										#
# ACCESS_MAP	Assign shorthand portals to portals as provisioned in S2	#
#										#
#################################################################################

set -euo pipefail

today=$(date +%Y%m%e)
output_file="$today-ingestion.csv"
log_file="$today-ingestion.log"

echo "Hi there!"
read -p "Please enter your raw csv filename: " input_file
echo "Thanks, friendo! Converting ACL list from $input_file."

#--- assign shorthand portals to access level tokes as provisioned in S2 ---#
declare -A ACCESS_MAP=(
  ["Main"]="Employee Access~~~FALSE~FALSE"
  ["IT"]="IT Work Room Access~~~FALSE~FALSE"
  ["Server"]="Server Closet~~~FALSE~FALSE"
  ["Storage"]="Storage Access~~~FALSE~FALSE"
  ["Photo"]="Photography Access~~~FALSE~FALSE"
  ["Master"]="Master Access~~~FALSE~FALSE"
)

#--- write csv header for output ---#
echo "COMMAND,PERSONID,PARTITION,FIRSTNAME,LASTNAME,EMAIL,ACCESSLEVELS,CREDENTIALS" > "$output_file"

#--- capture PersonID to increment ---#
read -p "Enter the starting _ID number: " start_id

#--- trim whitespace ---#
trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; echo "${s%"${s##*[![:space:]]}"}"; }

#--- convert "A; B; C" (or "A|B|C") to PIPE-joined access tokens ---#
portals_to_accesslevels() {
  local portals_raw="$1"
  local cleaned="${portals_raw//|/;}"   # accept | or ; as separator
  local IFS=';' ; local out=()
  read -ra items <<< "$cleaned"
  for p in "${items[@]}"; do
    local key
    key=$(echo "$(trim "$p")")
    key=$(echo "$key" | tr -s ' ')
    if [[ -n "${ACCESS_MAP[$key]+set}" ]]; then
      out+=("${ACCESS_MAP[$key]}")
    else
      echo "Unknown portal name: '$p'" >> "$log_file"
    fi
  done
  (IFS='|'; echo "${out[*]}")
}

#--- read raw csv file ---#
while IFS=',' read -r last first portals num email; do
  # skip header
  if [[ "$last" == "LASTNAME" ]]; then
    continue
  fi

  id="_$((start_id++))"

  acl="$(portals_to_accesslevels "${portals:-}")"
  hid_payload=""
  if [[ -n "${num:-}" ]]; then
    if [[ "$num" =~ ^10[0-2][0-9]{3}$ ]]; then
      hid_payload="${num}~${num}~Corporate 1000 48 bit~Active~~~"
    else
      echo "Invalid number for ${first} ${last}: $num" >> "$log_file"
      echo "Invalid number for ${first} ${last}: $num"
    fi
  fi

printf 'AddPerson,%s,Master,%s,%s,%s,{%s},{%s}\n' \
  "$id" "$first" "$last" "$email" \
  "$acl" "$hid_payload" >> "$output_file"

done < "$input_file"

dont_forget=$(( ${id#_} + 1 ))

echo "The last PersonID input was $id. You'll want to start the next user with _$dont_forget!"
echo "Please see $output_file for ingestion into the Lenel S2 system."
