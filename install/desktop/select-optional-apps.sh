#!/bin/bash

if [[ -v OLIKUB_FIRST_RUN_OPTIONAL_APPS ]]; then
	apps=$OLIKUB_FIRST_RUN_OPTIONAL_APPS

	if [[ -n "$apps" ]]; then
		for app in $apps; do
			installer="$OLIKUB_PATH/install/desktop/optional/app-${app,,}.sh"
			if [[ ! -f "$installer" ]]; then
				printf 'No optional app installer for selected item: %s\n' "$app" >&2
				return 1
			fi
			source "$installer"
		done
	fi
fi
