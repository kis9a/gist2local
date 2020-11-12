# Gist2localmd

### Summary

export the github gists of specified user to a local markdown file.

```
.
├── README.md
├── gist2localmd.sh
├── gists
   ├── test1.md
   └── test2.md
```

### Required

- **curl** - https://github.com/curl/curl
- **jq** https://stedolan.github.io/jq/

### Useage

```bash
git clone https://github.com/kis9a/gist2localmd
cd gist2localmd
sh ./gist2localmd.sh $auth_user $target_user

#example
sh ./gist2localmd.sh kis9a kis9a
```

### Reference

##### Github api overview

✅ Checkout

- https://api.github.com/
- https://api.github.com/users/kis9a
- https://api.github.com/users/kis9a/gists
- https://developer.github.com/v3/gists/
- https://developer.github.com/v3/#rate-limiting
- https://developer.github.com/v3/auth/#via-oauth-and-personal-access-tokens

##### Parse Json with jq

✅ Checkout

- https://stedolan.github.io/jq/
- https://qiita.com/ryo0301/items/2ac9d11f355f1cf52ea5
