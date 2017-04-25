#!/bin/bash
# .git/hooks/pre-commit update code snippet
# Reject commits which include tab indention
# - accepts an $AGAINST tree for comparison

if [[ -z "$AGAINST" ]]; then
    if git rev-parse --verify HEAD >/dev/null 2>&1
    then
        AGAINST=HEAD
    else
        # Initial commit: diff AGAINST an empty tree object
        AGAINST=4b825dc642cb6eb9a060e54bf8d69288fbee4904
    fi
fi

if [[ -z $GIT_DIFF ]]; then
    git_diff(){ git diff-index --cached $* $AGAINST; }
else
    git_diff(){ eval "$GIT_DIFF"; }
fi

EGG_INFO="$(git_diff --diff-filter=AM --name-only | grep -E '\.egg-info(/|$)')"
if [[ -n $EGG_INFO ]]; then
    echo "Found .egg-info in commit. Please remove the entries and retry. This command may help:"
    echo "    "git rm -r --cached $(echo "$EGG_INFO" | grep -E '\.egg-info/' | sed 's,/[^/]*$,,' | sort | uniq)
    echo
    exit 1
fi
