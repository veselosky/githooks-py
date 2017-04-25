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

# You must extract file contents of a commit or push via its hash, the filesystem cannot be trusted.
if [[ -z $GIT_DIFF ]]; then
    from_git(){ git diff-index --cached --diff-filter=AM $1 | awk '{print $4, $6}'; }
else
    from_git(){ git ls-tree $2 $(git diff --name-only $1 $2) | awk '{print $3, $4}'; }
fi

tab_check(){
    # replace indention tabs with ^I
    awk -v file=$1 '/^ *\t/{gsub("\t","^I"); print file ":" NR ": tabs used for indention of python."; print $0;}' /dev/stdin | \
    # Highlight the ^I strings and invert the return value
    (! grep --color=auto -B1 '\^I')
}

echo "## Checking for tab indention."
RET=0
# I HATE using a temp file for this, but |ing to 'while' calls a subshell, where <ing into it does not. Variables stored in a subshell aren't available to the calling shell.
COMMIT_TEMP=$(mktemp $GIT_DIR/COMMIT_TEMP.XXXXXX)
# test all Added or Modified .py files with tab_check 1 file at a time
from_git $AGAINST $NEW_HASH > $COMMIT_TEMP
while read hash name
do
    # test all Added or Modified .py files with tab_check 1 file at a time
    if [[ "${name##*.}" == "py" ]]; then
        git cat-file -p $hash | tab_check $name || RET=1
    fi
done < $COMMIT_TEMP
rm $COMMIT_TEMP

if [[ $RET != 0 ]]; then
    echo
    exit $RET
else
    echo "... pass"
    echo
fi
