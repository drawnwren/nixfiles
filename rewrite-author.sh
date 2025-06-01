#!/bin/sh

git filter-branch --env-filter '
if [ "$GIT_AUTHOR_EMAIL" = "drewulick@machindustries.com" ]
then
    export GIT_AUTHOR_EMAIL="drawnwren@gmail.com"
    export GIT_AUTHOR_NAME="drawnwren"
fi
if [ "$GIT_COMMITTER_EMAIL" = "drewulick@machindustries.com" ]
then
    export GIT_COMMITTER_EMAIL="drawnwren@gmail.com"
    export GIT_COMMITTER_NAME="drawnwren"
fi
' -- 842c6a048c16c2c485f4ff3544f2952aae986b5d..HEAD
