#!/bin/bash
# .git/hooks/commit update code snippet
# Reject commits with unchanged/default messages
# Requires that you copy COMMIT_EDITMSG to COMMIT_EDITMSG.orig in the prepare-commit-msg hook

# Notice: put the following in prepare-commit-msg
# Make a copy of this non-empty commit message so it can be compared by commit-msg.unchanged.sh in the commit-msg hook.
#    COMMIT_EDITMSG=$GIT_DIR/COMMIT_EDITMSG
#    cp "$COMMIT_EDITMSG" "$COMMIT_EDITMSG.orig"

REQUIRE_MERGE_MSG=1
COMMIT_EDITMSG=$GIT_DIR/COMMIT_EDITMSG

if [[ $GIT_EDITOR != ":" ]]; then
    # diff exits 0 if the files are the same
    if diff "$COMMIT_EDITMSG" "$COMMIT_EDITMSG.orig" >/dev/null && [[ ! -f $GIT_DIR/MERGE_HEAD || $REQUIRE_MERGE_MSG -eq 1 ]]; then
        echo "Aborting commit due to unchanged default commit message."
        exit 1
    fi
fi
