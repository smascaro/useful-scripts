#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No arguments provided"
	exit 1
fi

ssh_keys=$(ssh-add -L | grep "sergi@borneo.local" | wc -l | tr -d ' ')

if [ "$ssh_keys" -eq "0" ]; then
	echo "No ssh keys found, run first \`ssh-add\` to add one, then run again the script"
	exit 4
fi

while getopts "rm" flag; do
	case "$flag" in
		r)
			rebase=true
			if [ "$(git branch --show-current)" == "master" ] ; then
				echo "\033[0;31m$(tput bold)You can't rebase master with master. Use -m to update the branch.$(tput sgr0)"
				exit 4
			fi
			echo "Will rebase after checking out current branch"
			;;

		m)
			master=true
			echo "Will update only master"
			if [ "$(git branch --show-current)" != "master" ] ; then
				echo "\033[0;31m$(tput bold)Please switch first to master branch.$(tput sgr0)"
				exit 3 
			fi
			;;
		*) 
			echo "No arguments supplied"
			exit 2
			;;
	esac
done

export LANG=en_GB

current_status="$(git status --short | grep -E -v "^\?\?" | wc -l | tr -d ' ')"

if [ "$current_status" -eq "0" ]; then
	current_branch="$(git branch --show-current)"
	echo "\033[0;32m$(tput bold)Branch $current_branch is ready$(tput sgr0)"
	git checkout master
	git fetch --all
	git rebase upstream/master
	git checkout "$current_branch"
	if [ "$rebase" = true ] ; then
		git rebase master
	fi
else
	echo "\033[0;31m$(tput bold)Please clean first your staging area: $current_status changes found. Either commit them, stash them or roll them back to continue.$(tput sgr0)"
fi
