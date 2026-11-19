#!/bin/bash

source "$OLIKUB_PATH/lib/apps.sh"

CHOICES=(
	"Olikub        Update Olikub itself"
	"Ollama        Run LLMs, like Meta's Llama3, locally"
	"LazyGit       TUI for Git"
	"LazyDocker    TUI for Docker"
	"Neovim        Text editor that runs in the terminal"
	"Zellij        Adds panes, tabs, and sessions to the terminal"
	"<< Back       "
)

CHOICE=$(gum choose "${CHOICES[@]}" --height 10 --header "Update manually-managed applications")

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
	# Don't update anything
	echo ""
else
	APP_ID=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]')

	case "$APP_ID" in
	"olikub")
		source "$OLIKUB_PATH/bin/olikub-sub/update-olikub.sh"
		;;
	*)
		if ! APP_FILE="$(app_find "$APP_ID")"; then
			echo "error: unknown app: $APP_ID" >&2
			return 1
		fi
		app_run "$APP_FILE" install && gum spin --spinner globe --title "Update completed!" -- sleep 3
		;;
	esac
fi

clear
source "$OLIKUB_PATH/bin/olikub"
