#/bin/bash

echo "This script has a good chance of ANNIHILATING any work that was done directly on MapR's GitHub. It will not affect your workspace though, besides confronting you with conflicts from upstream."

git config --global core.autocrlf input
# in combination with the rest of the script, we will basically smash all Windows line endings as they go from upstream to downstream
GITWORKSPACE="/root/builds/github-alt"
pushd $GITWORKSPACE

# Each tuple is:
# 1. UPSTREAM repo
# 2. DOWNSTREAM repo
# 3. WORKSPACE repo (only needed for uniqueness, it could actually be anything, and in theory it should be safe for all tuples to use the same value for every tuple, but I don't want to test that theory)
#TUPLES="git@github.com:OpenTSDB/asynchbase.git git@github.com:mapr/asynchbase.git asynchbase git@github.com:OpenTSDB/asynchbase.git git@github.com:mapr/private-asynchbase.git private-asynchbase git@github.com:OpenTSDB/opentsdb.git git@github.com:mapr/opentsdb.git opentsdb git@github.com:OpenTSDB/opentsdb.git git@github.com:mapr/private-opentsdb.git private-opentsdb"

TUPLES="git@github.com:mapr/private-installer.git git@github.com:larsf/private-installer.git private-installer"


echo "$TUPLES" | while read UPSTREAM_REPO DOWNSTREAM_REPO WORKSPACE_REPO
do

    # Exact sequence of events for each tuple:
    # 1. clean workspace - nobody actually works on these, right?
    # 2. clone the DOWNSTREAM repo from github to the WORKSPACE repo
    # 3. in the WORKSPACE repo, add a remote to the UPSTREAM repo from github
    # 4. get all branches from the UPSTREAM repo
    # 5. track all branches from the UPSTREAM repo to the WORKSPACE repo
    # 6. force-merge, using the UPSTREAM repo as the authority in the event of any conflict
    # 7. push everything to the DOWNSTREAM repo
    # 8. when devs pull from the DOWNSTREAM repo, they will get conflicts and have to fix them!
    echo "full git-to-git in workspace $WORKSPACE_REPO"
    rm -rf $WORKSPACE_REPO
    echo "Waiting a minute before the next clone"
    sleep 60s
    git clone $DOWNSTREAM_REPO $WORKSPACE_REPO
    pushd $WORKSPACE_REPO
    echo "Now in: `pwd`"
    git fetch origin "+refs/tags/*:refs/tags/*"
    # the remote doesn't have to be named "upstream" but we name it so for convention
    git remote add --fetch upstream $UPSTREAM_REPO
    git fetch upstream "+refs/tags/*:refs/tags/*"
    git pull --all
    git fetch --all
    git fetch --tags

    # We are currently in what github.com has configured as the main branch for the DOWNSTREAM repo
    FIRST_BRANCH=`git branch | grep "\*" | cut -d " " -f 2`
    FORCE_PUSH_CMD="git push origin upstream/${FIRST_BRANCH}:${FIRST_BRANCH} --force"
    if [ "x${FIRST_BRANCH}" = "xmaster" ]; then
        ${FORCE_PUSH_CMD}
    elif [ "x${FIRST_BRANCH}" = "xtrunk" ]; then
        ${FORCE_PUSH_CMD}
    fi

    for branch in `git branch -a | grep "remotes/upstream" | grep -v HEAD`; do
        UPSTREAM_BRANCH=$branch
        LOCAL_BRANCH=${branch##*/}
        echo "upstream branch: $UPSTREAM_BRANCH"
        echo "local branch: $LOCAL_BRANCH"
        git branch --track $LOCAL_BRANCH $UPSTREAM_BRANCH
        git checkout $LOCAL_BRANCH
        git clean -f -d
        git checkout --

        # Strategy option is "ours" because, at this moment, "ours" is upstream
        git merge remotes/origin/$LOCAL_BRANCH --commit --no-edit --strategy=recursive --strategy-option=patience --strategy-option=ours
        # "not something we can merge" - branch doesn't exist in DOWNSTREAM repo, no harm done, it will get pushed later

        # in case of certain types of modify/delete conflicts
        git commit -a --no-edit --allow-empty-message
    done #done iterating over branches

    git push --all origin
    git push --tags origin
    popd #popping WORKSPACE_REPO

done #done iterating over tuples
popd #popping GITWORKSPACE for completeness

