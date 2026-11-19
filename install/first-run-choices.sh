#!/bin/bash

AVAILABLE_LANGUAGES=("Ruby on Rails" "Node.js" "Go" "PHP" "Python" "Elixir" "Rust" "Java")
SELECTED_LANGUAGES="Python"
export OLIKUB_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 10 --header "Select programming languages")

if [[ "$OLIKUB_FIRST_RUN_LANGUAGES" == *"Python"* ]]; then
  AVAILABLE_PYTHON_VERSIONS=("3.10" "3.11" "3.12" "3.13" "3.14" "3.15")
  SELECTED_PYTHON_VERSIONS="3.10","3.11","3.12","3.13","3.14","3.15"
  export OLIKUB_FIRST_RUN_PYTHON_VERSIONS=$(gum choose "${AVAILABLE_PYTHON_VERSIONS[@]}" --no-limit --selected "$SELECTED_PYTHON_VERSIONS" --height 7 --header "Select Python versions")
fi

AVAILABLE_DBS=("MySQL" "Redis" "PostgreSQL")
SELECTED_DBS=""
export OLIKUB_FIRST_RUN_DBS=$(gum choose "${AVAILABLE_DBS[@]}" --no-limit --selected "$SELECTED_DBS" --height 5 --header "Select databases (runs in Docker)")
