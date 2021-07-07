#
# Copyright (c) 2019 by Delphix. All rights reserved.
#

# Quotes strings for use with JSON. Fails if the number of arguments is not
# exactly one because it will not do what the user likely expects.
function jqQuote
{
  if [[ "$#" -ne 1 ]]; then
    log -d "Wrong number of arguments to jqQuote: $*"
  fi
  $DLPX_BIN_JQ -R '.' <<< "$1"
}

# In case the Solaris id binary does not support the flags user other one.
env >> /var/tmp/script_debug

UIDN=$(id -u "$USER_NAME")
if [[ $? -ne 0 ]]; then
  UIDN=$(/usr/xpg4/bin/id -u "$USER_NAME")
fi
GIDN=$(id -g "$USER_NAME")
if [[ $? -ne 0 ]]; then
  GIDN=$(/usr/xpg4/bin/id -g "$USER_NAME")
fi

CURRENT_REPO='{}'
CURRENT_REPO=$($DLPX_BIN_JQ ".uid = $(jqQuote "$UIDN")" <<< "$CURRENT_REPO")
CURRENT_REPO=$($DLPX_BIN_JQ ".gid = $(jqQuote "$GIDN")" <<< "$CURRENT_REPO")

echo "$CURRENT_REPO"
