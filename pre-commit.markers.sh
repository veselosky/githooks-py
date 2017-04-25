#!/bin/bash
# .git/hooks/pre-commit update code snippet
# Reject commits which include merge markers or trailing white space.
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

echo "## Checking for merge markers and trailing white space."
if ! git_diff --check; then
    echo
    exit 1
else
    echo "... pass"
    echo
fi
