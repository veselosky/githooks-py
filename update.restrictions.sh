#!/bin/bash
# .git/hooks/update code snippet
# Restricts access to $BRANCH to allow only $ALLOW_ONLY users
# - expects $BRANCH to be populated in the env. e.g. export BRANCH=${1##*/}
# - to define access: git config "restrictions.$BRANCH.allow-only" "rbronosky zhunter"

if [[ -z "$BRANCH" ]]; then echo '$BRANCH is not in your environment. You probably forget to export it.'; exit 2; fi

# the gnu-sed way
echo | sed -r 'p' 2>/dev/null 1>&2 && ESED='sed -r'
# the BSD sed way
echo | sed -E 'p' 2>/dev/null 1>&2 && ESED='sed -E'

ALLOW_ONLY=$(git config --get-regexp "^restrictions.$BRANCH.allow-only" | $ESED "s/restrictions.$BRANCH.allow-only *//")

if [[ -n "$ALLOW_ONLY" ]]; then
    echo "($(echo "$ALLOW_ONLY" | $ESED 's/ {1,}/|/g'))"
    USER=$(id -un)
    echo "Allowed commiters to $BRANCH: $ALLOW_ONLY"
    eval "
    case $USER in
        ($(echo "$ALLOW_ONLY" | $ESED 's/ {1,}/|/g'))
            echo "User $USER approved.";;
        (*)
            echo "Error: User $USER not authorized!"
            exit 1;;
    esac
    "
fi
