#!/bin/bash

# uiautomation_runner.sh
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


main() {
    # Allow us to use spaces in quoted file names in Bash Shell,
    # per http://stackoverflow.com/a/1724065/535054 (See Dennis Williamson's comment):
    saveIFS="$IFS"; IFS='';

    # ===== START: TYPICAL MODIFICATIONS =====
    # Configurable paths and names as suitable for your app under test:
    BASE_SIMULATORS_PATH="$HOME/Library/Developer/CoreSimulator/Devices"

    BASE_AUTOMATION_TEST_SCRIPTS_PATH="$HOME/Developer/clients/all/icpd/icpd-pkpd-calculator/PKPDCalculatorAutomationTests/"
    TEST_APP_NAME="PKPDCalculator"
    TEST_FILE="TestRunner.js"
    SIMULATOR_NAME="iPhone 5s" # Make this pull from command line, but default to something if nothing on the command line
    #SIMULATOR_NAME="iPad Air"
    TEST_RESULTS_OUTPUT_PATH="$HOME/Developer/clients/all/icpd/icpd-pkpd-calculator/PKPDCalculatorAutomationTests/TestResults/"
    # ===== END: TYPICAL MODIFICATIONS =====

    # Determine the UDID of the simulator we are to use. With Xcode 6.0.1, you can name the simulators as you wish,
    # and they are all given UDIDs that form part of the file path to get to the .app. We can read the device.plist
    # file instead each simulator directory, to figure out which one is ours.
    SIMULATOR_PATH=`_find_specific_simulator ${BASE_SIMULATORS_PATH} ${SIMULATOR_NAME}`

    # ===== RUN THE COMMAND =====
    _run_automation_instrument ${TEST_APP_NAME} ${BASE_AUTOMATION_TEST_SCRIPTS_PATH} ${TEST_FILE} ${SIMULATOR_PATH} ${SIMULATOR_NAME} ${TEST_RESULTS_OUTPUT_PATH}

    # Revert to the pre-existing IFS shell variable value so as not to leave shell with unintended side effects.
    IFS="$saveIFS"
}


# _find_app_path_navigating_chaging_guid
# Created by @idStar - Sohail Ahmed
# This script finds the guid for a given iOS simulator app. Use in a pipe to get the full path
#
# Usage:
# 	find_app_guid <"Simulator Path"> <"App Name.app">
#
# The Simulator Path should be something like: "$HOME/Library/Developer/CoreSimulator/Devices/05BB8391-CCB5-47D8-952E-BA3AF342C891"
# It is basically some parent folder under which recursive traversal would eventually find the app sought.
# The App Name should include the .app suffix. It should already be built for the simulator, in order for us to find it.
_find_app_path_navigating_chaging_guid() {
    # ===== LOCATIONS =====
    SIMULATOR_PATH=$1
    TEST_APP_NAME=$2

    cd ${SIMULATOR_PATH}

    # ===== RUN THE COMMAND =====
    FULL_APP_PATH=`find ${SIMULATOR_PATH} -name ${TEST_APP_NAME}`

    # ===== PROVIDE OUTPUT FOR PIPING =====
    echo ${FULL_APP_PATH}
}


# _find_specific_simulator
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
_find_specific_simulator() {
    # Reanimate command line parameters into nicely named variables:
    local LOCAL_BASE_SIMULATORS_PATH=$1  # The path that is the root of the various simulators that could be installed.
    local LOCAL_SIMULATOR_NAME=$2  # The custom simulator a user can give different simulator configurations, since the Xcode 6.0.1 iOS Simulator app

    # Construct the line we'll look for an exact match to in the plist file:
    local LOCAL_SIMULATOR_PLIST_VALUE_LINE="<string>$SIMULATOR_NAME</string>"

    # Loop through all devices to figure out which is a match
    for DEVICE_DIRECTORY in ${LOCAL_BASE_SIMULATORS_PATH}/*; do
        # Retrieve the number of matches to our search string in the 'device.plist' file in the iterated simulator directory:
        local NUM_MATCHES=$(grep "$LOCAL_SIMULATOR_PLIST_VALUE_LINE" "$DEVICE_DIRECTORY"/device.plist | wc -l)

        # Did this directory return one match?
        if [ ${NUM_MATCHES} -eq 1 ]; then
            # MATCHING_UDID=$(basename ${DEVICE_DIRECTORY})
            local LOCAL_SIMULATOR_PATH=${DEVICE_DIRECTORY} # We want this script to return the full path of the matching simulator
            echo "$LOCAL_SIMULATOR_PATH"
            break
        fi
    done
}


# _run_automation_instrument()
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
_run_automation_instrument() {
    # UIAutomation Template location - Accurate as at Xcode 6.0.1.
    local instruments_automation_template_path="/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate"

    # Reanimate command line parameters into properly named variables:
    local test_app_name=$1 # The first command line argument is a quoted string, containing the name of app we are to find in the iOS Simulator's dynamic list of app directories
    local base_automation_test_scripts_path=$2 #The second command line argument is a quoted string to the path where test scripts are stored, such as the one passed in as the next argument.
    local test_script_name=$3  # The third command line argument is a quoted string, containing the name of the JavaScript test file to run with Instruments' UIAutomation
    local simulator_path=$4 # The fourth command line argument is a quoted string, containing the path to a folder under which iOS Simulator apps can be found
    local simulator_name=$5 # The fifth argument is the custom name you've given to the simulator, per http://stackoverflow.com/a/24728406/535054
    local test_results_output_path=$6 # The sixth command line argument is a quoted string, containing the path to a directory in which UIAutomation test results should be placed

    # Derived / Found locations:
    local automation_test_script_path="$base_automation_test_scripts_path/$test_script_name"
    local fully_qualified_app_path=`_find_app_path_navigating_chaging_guid ${simulator_path} ${test_app_name}`

    # Switch directory into the output directly, b/c otherwise, occasionally, Instruments will dump a .trace file in the directory from which this script is launched.
    cd ${test_results_output_path}

    # ===== RUN THE COMMAND =====
    instruments -t ${instruments_automation_template_path} \
                -w ${simulator_name} \
                ${fully_qualified_app_path} \
                -e UIASCRIPT ${automation_test_script_path} \
                -e UIARESULTSPATH ${test_results_output_path}
}


main

