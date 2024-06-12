#!/bin/sh

LANG=en_GB

if [[ $# -eq 0 ]]; then
	echo "No arguments provided"
	exit 1
fi

ssh_keys=$(ssh-add -L | grep "sergi@borneo.local" | wc -l | tr -d ' ')

if [ "$ssh_keys" -eq "0" ]; then
	echo "No ssh keys found, run first \`ssh-add\` to add one, then run again the script"
	exit 4
fi

branch=$1

cmd_check_branch_exists="git show-ref --quiet $branch"

if [[ ! cmd_check_branch_exists ]]; then
	echo "Branch \"$branch\" could not be found."
	exit 2
fi

current_branch="$(git branch --show-current)"

if [[ current_branch = branch ]]; then
	echo "Can't refresh a branch that is currently checked out. Please move to another branch and try again."
	exit 5
fi
regexp="^android-app-(\\S*|\\s*)"
if [[ $branch =~ $regexp ]]; then
	echo "Branch $branch matched regular expression: (1) ${BASH_REMATCH[1]}, (2) ${BASH_REMATCH[2]}"
	exit 0
else
	echo "Branch name did not match expected regular expression - $branch"
	exit -1
fi

upstream=$(echo $branch | cut -d/ -f1)
length_local_branch=$(( $(echo $branch | wc -c | tr -d ' ') + 1 ))
length_remote_prefix=$(echo "$upstream/android-app-" | wc -c | tr -d ' ')
remote_branch=$(echo $branch | tail -c $((length_local_branch - length_remote_prefix)))

echo "Remote branch is $remote_branch"

if [[ "$upstream" != "martijn" ]] && [[ "$upstream" != "patrick.w" ]]; then
	echo "Upstream $upstream not known. Is the branch maybe a local branch?"
	exit 3
fi

git branch -D $branch
echo "Deleted branch $branch"

git fetch "ssh://git@gitlab.intranet.chordify.net:2222/$upstream/android-app.git" "$remote_branch"
git checkout -b "$branch" FETCH_HEAD