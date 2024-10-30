#!/bin/bash
#
# Sync two directories with rsync, but keep history to optimize the process.
# On subsequent runs it will only sync files added since last sync.
# This allows an easy continue in case script is interupted.
# This also helps with network connectivity to remotes since each file is 
# transfered by initiating new rsync command. This solves one issue I have
# faced when syncing large number of files and that is connection breaking
# if the process takes to long (in my case it was about 10hrs to transfer all
# the files).
#
# Accepts two arguments source and destination directory.
# Make sure source and destination do not end with a slash.
# Script assumes that both source and destination directory already exist. It
# is meant only to sync source content to destination content.
#
# When started it will output where it saves history. Do not delete that file!
# Delete history file if you want to re-sync from clean state.
#
# Example usage
# In parent directory of Audiobooks run:
# ./sync_with_history.sh Audiobooks user@xhostname:/media/ServerMedia/Audiobooks
# to sync files to a remote server. You'll need ssh access set up.
#
# To sync local directories simply run:
# ./sync_with_history.sh Audiobooks /path/to/destination/Audiobooks
# in the parent directory of Audiobooks.

# Create history file name
escaped1=$(echo $1 | tr / -)
escaped2=$(echo $2 | tr / -)
sync_with_history_done_list="sync_with_history_done_list-$escaped1-to-$escaped2"
echo "Saving history to $sync_with_history_done_list"
# Ensure sync_with_history_done_list exists
touch $sync_with_history_done_list

# List all not rsync-ed files to a list
find $1 -mindepth 1 -type f -printf '%P\n' | grep -vFf $sync_with_history_done_list > sync_with_history_todo_list
cat sync_with_history_todo_list | while read line
do
        echo "Sending: $line"
        echo "$line" > files-to-include
        # NOTE: use rsync -a if you want to keep permissions, owner, group etc.
        # I use -r because I don't need those.
        rsync -r --files-from=files-to-include $1/ $2/
        echo "$line" >> $sync_with_history_done_list
done

# Clean up. leave only sync_with_history_done_list
touch files-to-include
rm files-to-include
rm sync_with_history_todo_list