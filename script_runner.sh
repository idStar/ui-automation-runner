#!/bin/bash

# script_runner.sh
# Created by @idStar - Sohail Ahmed
# This script kicks off the automation.sh script, with pre-filled parameters (so the scripts we use can be more generic)
#
# Usage:
# 	script_runner.sh
#
# The idea is that you modify the variables in the section 'typical modifications' and then run this script from the command line.
# It will call the 'automation.sh' script, which will find your already built app in the iOS Simulator, and run the test file you requested.
#
# Note that the paths specified here must all be absolute; home directory relative paths with a tilda (~) don't work,
# although using $HOME does work.

# Allow us to use spaces in quoted file names in Bash Shell, per http://stackoverflow.com/a/1724065/535054 (See Dennis Williamson's comment):
saveIFS="$IFS"; IFS=''; 

# ===== START: TYPICAL MODIFICATIONS =====
# Configurable paths and names as suitable for your app under test:
BASE_SIMULATORS_PATH="$HOME/Library/Developer/CoreSimulator/Devices"
BASE_SCRIPT_PATH="$HOME/Developer/clients/all/icpd/icpd-pkpd-calculator/PKPDCalculatorAutomationTests/"
APP_NAME="PKPDCalculator"
TEST_FILE="TestRunner.js"
#SIMULATOR_NAME="iPhone 5s" # Make this pull from command line, but default to something if nothing on the command line
SIMULATOR_NAME="iPad Air"
RESULTS_PATH="$HOME/Developer/clients/all/icpd/icpd-pkpd-calculator/PKPDCalculatorAutomationTests/TestResults/"
# ===== END: TYPICAL MODIFICATIONS =====


# ===== LOCATIONS =====
# START: Determine where this script file is located.
# Credit: http://stackoverflow.com/a/246128/535054
# Reasoning: We assume any other custom scripts we rely on are co-located with us.
SOURCE="${BASH_SOURCE[0]}"
DIR="$( dirname "$SOURCE" )"
while [ -h "$SOURCE" ]
do 
  SOURCE="$(readlink "$SOURCE")"
  [[ ${SOURCE} != /* ]] && SOURCE="$DIR/$SOURCE"
  DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
done
SCRIPTS_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# END: Determine where this script file is located.
# We need that location in order to call our companion automation.sh command.


# Determine the UDID of the simulator we are to use. With Xcode 6.0.1, you can name the simulators as you wish,
# and they are all given UDIDs that form part of the file path to get to the .app. We can read the device.plist
# file instead each simulator directory, to figure out which one is ours.
SIMULATOR_PATH=$( ${SCRIPTS_PATH}/find_simulator.sh ${BASE_SIMULATORS_PATH} ${SIMULATOR_NAME} )


# ===== RUN THE COMMAND =====
${SCRIPTS_PATH}/automation.sh ${APP_NAME} ${BASE_SCRIPT_PATH} ${TEST_FILE} ${SIMULATOR_PATH} ${SIMULATOR_NAME} ${RESULTS_PATH}


# Revert to the pre-existing IFS shell variable value so as not to leave shell with unintended side effects.
IFS="$saveIFS" 