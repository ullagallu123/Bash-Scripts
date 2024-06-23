# initial git setup
#!/bin/bash

read -p "Enter decription": DESCRIPTION

read -p "Please enter commit message: " MESSAGE

read -p "Please enter URL of repo: " URL

read -p "Please enter branch name: " BRANCH

echo "$DESCRIPTION" >> README.md

git init

git add .

git commit -m "$MESSAGE"

git branch -M $BRANCH

git remote add origin $URL

git push -u origin $BRANCH