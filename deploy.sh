#!/bin/bash
cd ~/project/
commitID=`git log -n 1 --pretty="%h" -- Dockerfile`
sed -i '/^# Dockerfile/d' Singularity && echo -e "\n# Dockerfile commit ID: $commitID\n" >> Singularity
git config --global user.email "alcalan@iarc.fr"
git config --global user.name "Circle CI_$CIRCLE_PROJECT_REPONAME_$CIRCLE_BRANCH"
git add .
git status
git commit -m "circleCI deployment [skip ci]"
git push origin $CIRCLE_BRANCH

curl -H "Content-Type: application/json" --data "{\"source_type\": \"Branch\", \"source_name\": \"$CIRCLE_BRANCH\"}" -X POST https://registry.hub.docker.com/u/iarcbioinfo/svaba-nf/trigger/daf85e4f-5008-4944-b5a2-a7fe78a34618/
