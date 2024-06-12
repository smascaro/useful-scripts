#!/usr/bin/env python3

import argparse
import subprocess


#############
# Utilities #
#############

green = "\033[0;92m"
yellow = "\033[0;93m"
red = "\033[0;91m"

reset_color = '\033[0m'
bold = "\033[1m"

def print_error(msg):
	print(red + bold + msg + reset_color)

def print_neutral(msg):
	print(yellow + msg + reset_color)

def print_info(msg):
	print(bold + green + msg + reset_color)

####################
# Argument parsing #
####################

parser = argparse.ArgumentParser("refresh-remote-git")
parser.add_argument("-b", help="The name of the branch to refresh, should not be prefixed by the remote origin. If not specified, the currently checked out branch will be refreshed.", type=str, required=False)
parser.add_argument("-r", help="The remote origin name. Usually your colleague's name. Also their initial letter will work.", type=str, required=True)
args = parser.parse_args()

available_remotes = ["martijn", "Andreia"]

branch_name = args.b
remote_name = ""
for r in available_remotes:
	if args.r.lower() == r[0].lower() or args.r.lower() == r.lower():
		remote_name = r
		break

if remote_name == "":
	print_error("No remote could be found with supplied value '{args.r}'")
	exit(-1)


#######################################
# First check if SSH key has been set #
#######################################

ssh_check = subprocess.run(["ssh-add", "-L"], capture_output=True)
grep_key = subprocess.run(["grep", "sergi@borneo.local"], input=ssh_check.stdout, capture_output=True)
word_count = subprocess.run(["wc", "-l"], input=grep_key.stdout, capture_output=True)
trail_empty_space = subprocess.run(["tr", "-d", "' '"], input=word_count.stdout, capture_output=True)

keys_found = int(word_count.stdout.decode('utf-8').strip())

if keys_found == 0:
	exit(1)

print_info("SSH key was found")

def get_current_branch():
	current_branch_proc = subprocess.run(["git", "branch", "--show-current"], capture_output=True)
	return current_branch_proc.stdout.decode('utf-8').strip()
	
#############################################
# Now we check if the branch exists already #
#############################################

if branch_name == None:
	branch_name = get_current_branch()
	print_neutral(f"No branch specified, using current branch: {branch_name}")

check_branch_exists_proc = subprocess.run(['git', 'show-ref', "--quiet", branch_name], capture_output=True)

if int(check_branch_exists_proc.returncode) != 0:
	print_error(f'Branch "{branch_name}" does not exist. Can\'t refresh something that is not there.')
	exit(2)

print_info("Branch does exist.")


#######################################
# Check if there are unstaged changes #
#######################################

status_check_proc = subprocess.run(["git", "status", "--short"],capture_output=True)
grep_tracked_modified_files = subprocess.run(["grep", "-E", "-v", "^\\?\\?"], input=status_check_proc.stdout, capture_output=True)
line_count_proc = subprocess.run(["wc", "-l"], input=grep_tracked_modified_files.stdout, capture_output=True)

print_info(line_count_proc.stdout.decode('utf-8').strip() + " changes in staging area")
tracked_and_modified_count = int(line_count_proc.stdout.decode('utf-8').strip())

if tracked_and_modified_count != 0:
	print_error(f"Please clean first your staging area: {tracked_and_modified_count} change(s) found. Either commit them, stash them or roll them back to continue.")
	exit(3)


############################################################################
# Check out master if the currently checked out branch is the supplied one #
############################################################################

# current_branch_proc = subprocess.run(["git", "branch", "--show-current"], capture_output=True)

current_branch = get_current_branch()

print_info(f"Current branch is '{current_branch}'")
print_info(f"Selected branch is '{branch_name}'")

if current_branch == branch_name:
	subprocess.run(["git", "checkout", "master"])

#######################
# Delete local branch #
#######################

subprocess.run(["git", "branch", "-D", branch_name])

#######################
# Fetch remote branch #
#######################

fetch_url = f'ssh://git@gitlab.intranet.chordify.net:2222/{remote_name}/android-app.git'
local_branch_name_in_remote = branch_name.removeprefix("android-app-")

fetch_remote_branch_proc = subprocess.run(["git", "fetch", fetch_url, local_branch_name_in_remote])

if(int(fetch_remote_branch_proc.returncode) != 0):
	print_error("Something went wrong when fetching the remote branch. Hopefully its output has been also printed out...")
	exit(4)

#############################
# Checkout refreshed branch #
#############################

subprocess.run(["git", "checkout", "-b", branch_name, "FETCH_HEAD"])

exit(0)