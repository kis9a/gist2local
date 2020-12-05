#!/bin/bash

exec_mode='test' # 'production' or 'test'
mock_file='./gists.json'
output_dir='./gists'

# check exec_mode status
if [ $exec_mode != 'production' -a $exec_mode != 'test' ] ; then
  echo 'ERROR: set correct status'
  exit 1
fi

## read gists or mock_file
if [ $exec_mode = 'test' ] ; then
  if [ -f $mock_file ] ; then
    gists=$(cat $mock_file)
  else
    echo 'dont exit mock files, get gists and output mock_file'
    $(curl -u $1 https://api.github.com/users/$2/gists -o $mock_file)
    gists=$(cat $mock_file)
  fi
else
  gists=$(curl -u $1 https://api.github.com/users/$2/gists)
fi

## set output directory
$(rm -rf $output_dir) && $(mkdir $output_dir)

## set get gist_files times set. if exec_mode='test' will get 2 times get
if [ $exec_mode = 'test' ]  ; then
  gists_length=2
else
  gists_length=$(echo $gists | jq length)
fi


## gists export local markdown files
for i in $( seq 0 $(($gists_length - 1))); do
  gist=$(echo $gists | jq .[$i])
  gist_files=$(echo $gist | jq ".files" -r)
  gist_files_length=$(echo $gist_files | jq length)
  gist_file_names=$(echo $gist_files | jq keys)

  echo $gist_files_length

  for n in $( seq 0 $(($gist_files_length -1))); do
    gist_file=$(echo $gist_files | jq ."$(echo $gist_file_names | jq .[$n])" -r)
    gist_file_name=$(echo $gist_file | jq ."filename" -r)
    gist_raw_url=$(echo $gist_file | jq ."raw_url" -r)
    $(curl $gist_raw_url -o $output_dir/"$gist_file_name".md)
  done
done
