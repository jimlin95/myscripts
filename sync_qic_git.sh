#!/bin/sh 
#repo forall -c 'git remote add lc git://10.241.119.3/TI_OMAP4_3CBU/${REPO_PROJECT}.git'
#repo forall -c 'git fetch lc'
#repo forall -c 'git co -t qic-release/Gen2B_TI_OMAP4_L27.IS.E2'
#repo forall -c 'echo $REPO_PROJECT & git rebase qic-release/Gen2B_TI_OMAP4_L27.IS.E2'
repo forall -c 'echo $REPO_PROJECT & git push lc Gen2B_TI_OMAP4_L27.IS.E2'
exit 0

