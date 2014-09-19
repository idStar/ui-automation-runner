#!/bin/bash

# find_simulator.sh
# Created by @idStar - Sohail Ahmed
# This script finds the full path to the custom named iOS simulator you specify. To do that, it will need the
# base path at which simulators live. This seems to change frequently between Xcode releases, so the expectation
# is that you will pass that in as the first parameter to this script invocation.
#
# This script is chainable, as we echo back the result of our search.
# That is, you can pipe our result into another command.
#
# Usage:
# 	find_simulator <"Base Simulators Path"> <"Simulator Name">
#
# The Base Simulators Path should be something like: "$HOME/Library/Developer/CoreSimulator/Devices"
# It is basically some parent folder under which all installed iOS simulators exist.
# The Simulator Name is what you named your simulator in the custom simulators configuration/install,
# within the iOS Simulator app.


# Reanimate command line parameters into nicely named variables:
BASE_SIMULATORS_PATH=$1  # The path that is the root of the various simulators that could be installed.
SIMULATOR_NAME=$2  # The custom simulator a user can give different simulator configurations, since the Xcode 6.0.1 iOS Simulator app

# Construct the line we'll look for an exact match to in the plist file:
SIMULATOR_PLIST_VALUE_LINE="<string>$SIMULATOR_NAME</string>"

# Loop through all devices to figure out which is a match
for DEVICE_DIRECTORY in ${BASE_SIMULATORS_PATH}/*; do
    #echo ${DEVICE_DIRECTORY}
    # Retrieve the number of matches to our search string in the 'device.plist' file in the iterated simulator directory:
    NUM_MATCHES=$(grep "$SIMULATOR_PLIST_VALUE_LINE" "$DEVICE_DIRECTORY"/device.plist | wc -l)

    # Did this directory return one match?
    if [ ${NUM_MATCHES} == "1" ]; then
        echo ${DEVICE_DIRECTORY} # We want this script to return the full path of the matching simulator

        # MATCHING_UDID=$(basename ${DEVICE_DIRECTORY})
        # echo "Matching Device Directory is:" ${DEVICE_DIRECTORY}
        # echo "Matching Device Directory UDID is:" ${MATCHING_UDID}
    fi
done
