#!/bin/bash

exec_mode='production' # 'production' or 'test'
mock_file='./gists.json'
output_dir='./gists'

# check exec_mode
if [ $exec_mode != 'production' -a $exec_mode != 'test' ] ; then
  echo 'ERROR: set correct status'
  exit 1
fi

## GET gists or read mock_file
if [ $exec_mode = 'test' ] ; then
  if [ -f $mock_file ] ; then
    declare -a gists=$(cat $mock_file)
  else
    echo 'dont exit mock files, get gists and output mock_file'
    $(curl -u $1 https://api.github.com/users/$2/gists -o $mock_file)
    declare -a gists=$(cat $mock_file)
  fi
else
  declare -a gists=$(curl -u $1 https://api.github.com/users/$2/gists)
fi

## set output directory
$(rm -rf $output_dir) && $(mkdir $output_dir)

## set gist_files getting times. if exec_mode='test' will two times get
if [ $exec_mode = 'test' ]  ; then
  declare -i gists_length=2
else
  declare -i gists_length=$(echo $gists | jq length)
fi

## gists export local markdown files
for i in $( seq 0 $(($gists_length - 1))); do
  gist=$(echo $gists | jq .[$i])
  gist_files=$(echo $gist | jq ".files" -r)
  declare -i gist_files_length=$(echo $gist_files | jq length)
  gist_file_names=$(echo $gist_files | jq keys)

  if [ $gist_files_length = 0 ] ; then
    echo 'dont exit gist_files in this gist'
    exit;
  fi

  for n in $( seq 0 $(($gist_files_length -1))); do
    gist_file=$(echo $gist_files | jq ."$(echo $gist_file_names | jq .[$n])" -r)
    gist_file_name=$(echo $gist_file | jq ."filename" -r)
    gist_raw_url=$(echo $gist_file | jq ."raw_url" -r)
    $(curl $gist_raw_url -o $output_dir/"$gist_file_name".md)
  done
done
