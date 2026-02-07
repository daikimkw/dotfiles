#!/bin/bash

if ! command -v brew &>/dev/null; then
  git clone --depth=1 https://github.com/Homebrew/brew "$HOME/.homebrew"
fi
