#!/usr/bin/env bash

# Check if a commit message was provided
if [ $# -eq 0 ]; then
    echo "Error: No commit message provided. Please run the script with a commit message."
    echo "Usage: $0 <commit message>"
    exit 1
fi

cd $HOME/zaneyos
# Remove .gitignore if it exists
[ -f .gitignore ] && rm .gitignore

# Create .gitignore_sav if it doesn't exist
if [ ! -f .gitignore_sav ]; then
    cat > .gitignore_sav << 'EOF'
config/myAliases.txt
config/quickmarks
config/scripts.sh
config/ssh_config
config/urls_newsboat
flake.nix
EOF
fi

# This file got alot simpler with gitignore
#
# hide my private info with a public stub
# cd $HOME
# public.sh

#add, commit and push
git add *
mv .gitignore_sav .gitignore
git commit -m "$1"
git push -u origin main
mv .gitignore .gitignore_sav

# restore my private info and sync. I think the sync is not necessary, so I will comment it out.
# cd $HOME
# private.sh
#phoenix sync user

