#!/usr/bin/env bash

##############################################################
# Author: kis9a <kis9ax@gmail.com>                           #
# Info: https://github.com/kis9a/gist2localmd#gist2localmd   #
# Template: https://github.com/kis9a/bashtemplate            #
# License: MIT                                               #
##############################################################

# --- Template --- {{{
# color pallet
readonly cf="\\033[0m"
readonly red="\\033[0;31m"
readonly green="\\033[0;32m"
readonly yellow="\\033[0;33m"
readonly purple="\\033[0;35m"

#catch getting closed and interrupted by ctrl+c
trap exit_EXIT EXIT
trap exit_CTRL QUIT SIGINT

# The err() function redirects output to STDERR
err() {
  local _date
  _date=$(showdate)
  echo -e "[$_date][${red}ERROR${cf}]: $1" 1>&2
}

# The err_die() function redirects the message to STDERR,
# starts the cleanup function and then exits.
# You can call err_die() with "1" as argument to show the help before exiting.
err_die() {
  local _date
  _date=$(showdate)
  echo -e "[$_date][${red}ERROR${cf}]: $1 -> use -h parameter for help." 1>&2
  echo -e "[$_date][${red}ERROR${cf}]: Cleaning & Exiting."
  if [[ "$2" == "1" ]]; then
    showhelp
  fi
  exit 1 #or use $2 instead of 1 to work with exit arguments
}

# The following function warn, info, succ and debug are for
# output information, use warn for warnings, succ for success etc.
# You can change the colors at the top.
warn() {
  local _date
  _date=$(showdate)
  echo -e "[$_date][${yellow}WARNING${cf}]: $1"
}

info() {
  local _date
  _date=$(showdate)
  echo -e "[$_date][INFO]: $1 "
}

succ() {
  local _date
  _date=$(showdate)
  echo -e "[$_date][${green}SUCCESS${cf}]: $1"
}

showdate() {
  local _date
  _date=$(date +%d-%H.%M)
  echo "$_date"
}

# The debug() funktion will only show up if boolean 'is_debug' is true
debug () {
  local _date
  _date=$(showdate)
  if [[ "$is_debug" == "true" ]]; then
    echo -e "[$_date][${purple}DEBUG${cf}]: $1"
  fi
}

exit_EXIT() {
  info "Script ended! Cleanup & Exit."
  cleanup
  exit 1
}

exit_CTRL() {
  err "User pressed CTRL+C!"
  exit 1
}

cleanup() {
  info "cleanup.."
  # cleanup tmp files, kill process etc.
}

showhelp() {
  echo ""
  echo " Usage:"
  echo "   bash $0 'auth_user' 'target_user'"
  echo ""
  echo " Flags:"
  echo "  -d: For optional debug messages."
  echo "  -h: Shows this help text."
  echo " "
  echo " Examples:"
  echo "   bash gist2localmd -h"
  echo "   bash gist2localmd -d"
  echo "   bash gist2localmd.bash kis9a kis9a"
  echo ""
  echo " Info:"
  echo "  ./README.md"
  echo "  https://github.com/kis9a/gist2localmd#gist2localmd "
  echo ""
}

# Add all the parameter you whish, -h will show help and -d will
# trigger debug messages to show up
while getopts ":hd" o; do
    case "${o}" in
        h)
            showhelp
            exit 1
            ;;
        d)
            is_debug=true
            ;;
        *)
            err "No valid option choosed."
            ;;
    esac
done

is_exists() {
    which "$1" >/dev/null 2>&1
    return $?
}
#}}}

# set initialize variables

is_debug=false
gists_json_file="./gists.json"
gists_output_directory='./gists'

get_user_gists_json() {
  if $is_debug; then
      : # write your debug code
  else
    # check arguments
    if [ -z "$1" ]; then
      showhelp
      err "First argument 'auth_user' is not supplied"
      exit 1
    fi
    if [ -z "$2" ]; then
      showhelp
      err "Second arguments 'target_user' is not supplied"
      exit 1
    fi

    # check is exit curl command
    if is_exists "curl"; then
      curl -s -u "$1" https://api.github.com/users/"$2"/gists -o $gists_json_file
    fi

    # check isexit outputed file
    if [ -e $gists_json_file ]; then
      succ 'Created user gists json file'
    else
      err "Can't created user gist json file"
      exit
    fi
  fi
}

gist_to_local_markdown() {

  ## set output directory
  rm -rf "$gists_output_directory"
  mkdir "$gists_output_directory"

  # check isexit and read json file
  if [ -e $gists_json_file ]; then
    gists=$(jq "." < "$gists_json_file")
  else
    err "can't source gist json file"
    exit
  fi

  # parse to array of file_objs
  gist_file_objs=$(echo "$gists" | jq ".[] .files|to_entries[]|.value" | jq -s)

  # download with curl by get filename and raw_url
  for num in $( seq 1 "$(echo "$gist_file_objs" | jq length)"); do
    filename=$(echo "$gist_file_objs" | jq -r .["$num]|.filename")
    raw_url=$(echo "$gist_file_objs" | jq -r .["$num]|.raw_url")

    echo "$raw_url" "$gists_output_directory"/"$filename"
    curl -s "$raw_url" -o "$gists_output_directory"/"$filename".md
  done
}

main() {
  get_user_gists_json "$1" "$2"
  gist_to_local_markdown
}

main "$1" "$2"
