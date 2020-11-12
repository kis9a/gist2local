#!/bin/bash

exec_mode='production' # 'production' or 'test'
mock_file='./gists.json'
output_dir='./gists'
get_gists=`curl -u $1 https://api.github.com/users/$2/gists`

## read gists
if [ $exec_mode = 'test' ] ; then
  if [ -f $mock_file ] ; then
    gists=$(cat $mock_file)
  else
    echo 'not mock files'
    gists=$($get_gists -o $mock_file)
    gists=$(cat $mock_file)
  fi
elif [ $exec_mode = 'production' ] ; then
  gists=$($get_gists)
else
  echo 'ERROR: set correct status'
  exit 1
fi

echo $gists

## set output directory
if [ -d $output_dir ] ; then
  $(rm $output_dir/*)
else
  $(mkdir $output_dir )
fi

gists_length=$(echo $gists | jq length)

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
