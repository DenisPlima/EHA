#!/usr/bin/python

import os
import sys

from include.helper_func import *

"""
Constant declarations
"""
REPO_NAME_INDEX = 0
REPO_ADDR_INDEX = 1

# Repository addresses
GIT_REPOS = [# Repo name, Repo address
            ["KOIT",    "https://github.com/Project-Bonfire/KOIT.git"],
            ["EHA",     "https://github.com/Project-Bonfire/EHA.git"],
            ["Test",    "https://github.com/Project-Bonfire/Test.git"],
            ["FPGA-integration",    "https://github.com/Project-Bonfire/FPGA-integration.git"]]

# Local source directory used for storing the repos
SRC_DIR = "../src"

# Make the terminal beautiful
#helper_func = HelperFunctions()

"""
Funcitons
"""

def git_clone(local_path, repo_address):
    """
    Execute git clone.

    local_path: string      - path to local repository (including repository's folder)
    repo_address: string    - address of the git repo

    return: int - return value of the git clone command
    """
    # Run git clone on the specified repo
    return os.system("git clone " + repo_address + " " + local_path)


def git_pull(local_path):
    """
    Execute git pull.

    local_path: string      - path to local repository (including repository's folder)

    return: int - return value of the git pull command
    """
    # Run git pull on the specified repo
    current_path = os.getcwd()
    os.chdir(local_path)

    return_value = os.system("git pull") # Cannot use the -C flag, does not work on some git versions

    os.chdir(current_path)

    return return_value

"""
Main program
"""

def main(argv):
    # Check if directory exists, create if not
    print_msg(MSG_INFO, "Checking for sources folder...")
    if check_dir(SRC_DIR, True) < 0:
        sys.exit(1)

    print_msg(MSG_INFO, "Checking repos...")
    for repo in GIT_REPOS:
        return_value = check_dir(SRC_DIR + "/" + repo[REPO_NAME_INDEX], False)

        if return_value < 0:
            sys.exit(1)
        elif return_value == DIR_EXISTS:
            print_msg(MSG_BLUE_INFO, "Repo " + repo[REPO_NAME_INDEX] + " found on local system. Pulling changes.")
            if git_pull(SRC_DIR + "/" + repo[REPO_NAME_INDEX]) != 0:
                print_msg(MSG_ERROR, "Git pull unsuccessful. Manual action required")
                sys.exit(1);
        elif return_value == DIR_NOT_EXISTS:
            print #empty line
            print_msg(MSG_BLUE_INFO, "Cloning repo " + repo[REPO_NAME_INDEX])
            if git_clone(SRC_DIR + "/" + repo[REPO_NAME_INDEX], repo[REPO_ADDR_INDEX]) != 0:
                print_msg(MSG_ERROR, "Error cloning repo")
                sys.exit(1);

if __name__ == "__main__":
    main(sys.argv)
