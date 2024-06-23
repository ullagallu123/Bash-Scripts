#!/bin/bash

read -p "Please enter commit message: " COMMIT_MESSAGE

read -p "Please enter branch name: " BRANCH_NAME

git add .

git commit -m "$COMMIT_MESSAGE"

git push origin "$BRANCH_NAME"

