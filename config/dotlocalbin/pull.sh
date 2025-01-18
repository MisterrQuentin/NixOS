#!/usr/bin/env bash

#add, commit and push
cd $HOME/zaneyos
git pull

# Remove .gitignore if it exists
[ -f .gitignore ] && rm .gitignore

