#!/bin/bash
# .git/hooks/commit update code snippet
# Reject commits which were passed the -m flag

# -m passed to commit
if [[ $GIT_EDITOR == ":" ]]; then
    echo "Aborting commit due to use of -m flag."
    exit 1
fi
