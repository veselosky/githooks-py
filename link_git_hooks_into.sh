#!/bin/bash
#
# Symlinks all the executables in the githooks repo (this one) into the .git/hooks
# folders of every passed (as arguments to this script) repo.
# Call this script with a list of git repos (not the .git dirs) as arguments.

SCRIPTS=$(find $(dirname $0) -maxdepth 1 -type f -perm +0111 | grep -v $(basename $0))

fullpath(){ (cd $(dirname $1); echo $(pwd)/$(basename $1)); }

for d in $*; do
    dir="${d%/}/.git/hooks/"
    if [[ ! -d "$dir" ]]; then
        dir2="${d%/}/hooks/"
        if [[ ! -d "$dir2" ]]; then
            echo "Could not find $dir or $dir2. Skipping..."
            continue
        else
            dir=$dir2
        fi
    fi
    ln -s $(for f in $SCRIPTS; do fullpath $f; done) $dir
done
