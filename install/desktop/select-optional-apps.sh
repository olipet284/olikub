#!/bin/bash

if [[ -v OLIKUB_FIRST_RUN_OPTIONAL_APPS ]]; then
	apps=$OLIKUB_FIRST_RUN_OPTIONAL_APPS

	if [[ -n "$apps" ]]; then
		for app in $apps; do
			source "$OLIKUB_PATH/install/desktop/optional/app-${app,,}.sh"
		done
	fi
fi
