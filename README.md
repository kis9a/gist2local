# gist2localmd

Export the github gists of specified user to a local markdown files with GitHub api 3.  
I had used github gist to personal memos, snippets, but I don't necessary it for me.  
Because, 1.extra version history each kind of memos, snippets.  
2. private gist is not private completely. 3.not speedy for edit,search and sync.  
So migration to [kis9a/notes](https://github.com/kis9a/notes/tree/master/memos) and manage with with unix commands.  

## PS

**I got it, Shell input/output is just a string**.

```sh
curl -s https://api.github.com/users/$target_user/gists  
  | grep \"raw_url\" | awk '{print $2}'  
  | sed -e 's/"//g' -e 's/,//g' | xargs -n1 curl -O
```

## Required

- *[stedolan/jq](https://github.com/stedolan/jq): Command-line JSON processor ...
- [curl/curl](https://github.com/curl/curl): Command-line tool and library for transferring data with URL syntax ...

## Useage

```sh
git clone https://github.com/kis9a/gist2localmd.git
sh ./gist2localmd.sh $auth_user $target_user
```

## Reference

#### GitHub api v3 overview
- https://developer.github.com/v3/gists/
- https://developer.github.com/v3/#rate-limiting
- https://developer.github.com/v3/auth/#via-oauth-and-personal-access-tokens

#### Response example
- https://api.github.com/
- https://api.github.com/users/kis9a
- https://api.github.com/users/kis9a/gists

#### Development used

reading ...
- https://github.com/google/styleguide/blob/gh-pages/shellguide.md
- https://github.com/josa42/coc-sh
