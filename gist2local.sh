#!/bin/bash

$(rm gists.json)
$(rm -rf gists)
$(mkdir gists)
$(curl -u kis9a https://api.github.com/users/kis9a/gists >> gists.json)

gists=$(cat gists.json)
gists_length=$(jq length ./gists.json)

for i in $( seq 0 $(($gists_length - 1))); do
  gist=$(echo $gists | jq .[$i])
  gist_files=$(echo $gist | jq ".files" -r)
  gist_files_length=$(echo $gist_files | jq length)
  gist_file_names=$(echo $gist_files | jq keys)

  for n in $( seq 0 $(($gist_files_length -1))); do
    gist_file=$(echo $gist_files | jq ."$(echo $gist_file_names | jq .[$n])" -r)
    gist_file_name=$(echo $gist_file | jq ."filename" -r)
    gist_raw_url=$(echo $gist_file | jq ."raw_url" -r)
    $(curl $gist_raw_url --output ./gists/"$gist_file_name".md)
  done
done

