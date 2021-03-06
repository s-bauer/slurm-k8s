#!/bin/bash

# Taken from github.com/rootless-containers/usernetes and modified
# License: https://github.com/rootless-containers/usernetes/blob/master/LICENSE

set -euo pipefail

function log::debug() {
	echo -e "\e[102m\e[97m[DEBUG]\e[49m\e[39m $@"
}

function log::info() {
	echo -e "\e[104m\e[97m[INFO]\e[49m\e[39m $@"
}

function log::info_n() {
	echo -n -e "\e[104m\e[97m[INFO]\e[49m\e[39m $@"
}

function log::warning() {
	echo -e "\e[101m\e[97m[WARN]\e[49m\e[39m $@"
}

function log::error() {
	echo -e "\e[101m\e[97m[ERROR]\e[49m\e[39m $@"
}

# nsenter utilities
function nsenter::main() {
	: ${_U7S_NSENTER_CHILD=0}
	if [[ $_U7S_NSENTER_CHILD == 0 ]]; then
		_U7S_NSENTER_CHILD=1
		export _U7S_NSENTER_CHILD
		nsenter::_nsenter_retry_loop
		rc=0
		nsenter::_nsenter $@ || rc=$?
		exit $rc
	fi
}

function nsenter::_nsenter_retry_loop() {
	local max_trial=10
	log::info_n "Entering RootlessKit namespaces: "
	for ((i = 0; i < max_trial; i++)); do
		rc=0
		nsenter::_nsenter echo OK 2>/dev/null || rc=$?
		if [[ rc -eq 0 ]]; then
			return 0
		fi
		echo -n .
		sleep 1
	done
	log::error "nsenter failed after ${max_trial} attempts, RootlessKit not running?"
	return 1
}

function nsenter::_nsenter() {
	local pidfile=$XDG_RUNTIME_DIR/slurm-k8s/rootlesskit/child_pid
	if ! [[ -f $pidfile ]]; then
		return 1
	fi

	export ROOTLESSKIT_STATE_DIR=$XDG_RUNTIME_DIR/slurm-k8s/rootlesskit
	nsenter --user --preserve-credential --mount --net --cgroup --pid --ipc --uts -t $(cat $pidfile) --wd=$PWD -- $@
}

# verify necessary environment variables
if ! [[ -w $XDG_RUNTIME_DIR ]]; then
	log::error "XDG_RUNTIME_DIR needs to be set and writable"
	return 1
fi

if ! [[ -w $HOME ]]; then
	log::error "HOME needs to be set and writable"
	return 1
fi


# export XDG_{DATA,CONFIG,CACHE}_HOME
: ${XDG_DATA_HOME=$HOME/.local/share}
: ${XDG_CONFIG_HOME=$HOME/.config}
: ${XDG_CACHE_HOME=$HOME/.cache}
export XDG_DATA_HOME XDG_CONFIG_HOME XDG_CACHE_HOME
