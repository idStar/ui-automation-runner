#!/bin/bash

# automation.sh
# Created by @idStar - Sohail Ahmed
# This script launches the UIAutomation Instrument targeting a pre-existing iOS Simulator app, from the command line.
# Works with Xcode 4.4.1 on Mountain Lion
#
# Usage:
# 	automation  <"App Name.app"> \
#               <"base test script path"> \
#               <"testFile.js"> \
#               <"resolved iOS Simulator path"> \
#               <"you custom iOS Simulator name"> \
#               <"results output directory">
#
# Example:
# 	automation.sh   "MyApp.app" \
#                   "$HOME/Developer/apps/MyApp/UIAutomation/tests" \
#                   "TestRunner.js" \
#                   "$HOME/Library/Developer/CoreSimulator/Devices/05BB8391-CCB5-47D8-952E-BA3AF342C891" \
#                   "iPhone 5s" \
#                   "$HOME/Developer/apps/MyApp/UIAutomation/runs"


# Allow us to use spaces in quoted file names in Bash Shell,
# per http://stackoverflow.com/a/1724065/535054 (See Dennis Williamson's comment):
saveIFS="$IFS"; IFS=''; 


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


# UIAutomation Template location - Accurate as at Xcode 6.0.1.
INSTRUMENTS_TEMPLATE="/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate"

# Reanimate command line parameters into properly named variables:
APP_NAME=$1 # The first command line argument is a quoted string, containing the name of app we are to find in the iOS Simulator's dynamic list of app directories
BASE_SCRIPT_PATH=$2 #The second command line argument is a quoted string to the path where test scripts are stored, such as the one passed in as the next argument.
SCRIPT_NAME=$3  # The third command line argument is a quoted string, containing the name of the JavaScript test file to run with Instruments' UIAutomation
SIMULATOR_PATH=$4 # The fourth command line argument is a quoted string, containing the path to a folder under which iOS Simulator apps can be found
SIMULATOR_NAME=$5 # The fifth argument is the custom name you've given to the simulator, per http://stackoverflow.com/a/24728406/535054
RESULTS_PATH=$6 # The sixth command line argument is a quoted string, containing the path to a directory in which UIAutomation test results should be placed

# Derived / Found locations:
SCRIPT_PATH="$BASE_SCRIPT_PATH/$SCRIPT_NAME"
APP_PATH=`${SCRIPTS_PATH}/find_app_guid.sh ${SIMULATOR_PATH} ${APP_NAME}`

# Switch directory into the output directly, b/c otherwise, occasionally, Instruments will dump a .trace file in the directory from which this script is launched.
cd ${RESULTS_PATH}


# ===== RUN THE COMMAND =====
instruments -t ${INSTRUMENTS_TEMPLATE} -w ${SIMULATOR_NAME} ${APP_PATH} -e UIASCRIPT ${SCRIPT_PATH} -e UIARESULTSPATH ${RESULTS_PATH}


# Revert to the pre-existing IFS shell variable value so as not to leave shell with unintended side effects.
IFS="$saveIFS" 