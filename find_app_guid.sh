#!/bin/bash

# find_app_guid.sh
# Created by @idStar - Sohail Ahmed
# This script finds the guid for a given iOS simulator app. Use in a pipe to get the full path
#
# Usage:
# 	find_app_guid <"Simulator Path"> <"App Name.app">
#
# The Simulator Path should be something like: "$HOME/Library/Developer/CoreSimulator/Devices/05BB8391-CCB5-47D8-952E-BA3AF342C891"
# It is basically some parent folder under which recursive traversal would eventually find the app sought.
# The App Name should include the .app suffix. It should already be built for the simulator, in order for us to find it.


# Allow us to use spaces in quoted file names in Bash Shell,
# per http://stackoverflow.com/a/1724065/535054 (See Dennis Williamson's comment):
saveIFS="$IFS"; IFS=''; 

# ===== LOCATIONS =====
SIMULATOR_PATH=$1
APP_NAME=$2

cd ${SIMULATOR_PATH}

# ===== RUN THE COMMAND =====
FULL_APP_PATH=`find ${SIMULATOR_PATH} -name ${APP_NAME}`

# ===== PROVIDE OUTPUT FOR PIPING =====
echo ${FULL_APP_PATH}


# Revert to the pre-existing IFS shell variable value so as not to leave shell with unintended side effects.
IFS="$saveIFS" 