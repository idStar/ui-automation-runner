#!/bin/bash

# ui_automation_runner.sh
# Created by @idStar - Sohail Ahmed
# This script kicks off the automation.sh script, with pre-filled parameters (so the scripts we use can be more generic)
#
# Usage:
# 	ui_automation_runner.sh
#
# The idea is that you modify the variables in the section 'typical modifications' and then run this script from the command line.
# It will call the 'automation.sh' script, which will find your already built app in the iOS Simulator, and run the test file you requested.
#
# Note that the paths specified here must all be absolute; home directory relative paths with a tilda (~) don't work,
# although using $HOME does work.


# ===== CONFIGURABLE OPTIONS =====
# Set this to true if you want debug output
DEBUG_MODE_ENABLED=0 # Set to 1 for true (debugging enabled), or 0 for false (debugging statements suppressed).



# ---------- DO NOT EDIT ANYTHING BELOW THIS LINE, UNLESS YOU KNOW WHAT YOU'RE DOING -----------

# ===== GLOBAL CONSTANTS =====
# This is where Xcode installs simulators. Accurate as at Xcode 6.0.1.
BASE_SIMULATORS_PATH="$HOME/Library/Developer/CoreSimulator/Devices"


# UIAutomation Instruments Template location. Accurate as at Xcode 6.0.1.
INSTRUMENTS_AUTOMATION_TEMPLATE_PATH="/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents"\
"/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate" # DO NOT CHANGE INDENTATION!



# ===== COMMAND LINE ARGUMENTS RETRIEVAL =====

# Place the command line arguments to this shell script into global variables that other functions will be
# able to make use of. All of these parameters are mandatory, otherwise we'll messs up downstream function calls.
SIMULATOR_NAME_OR_DEVICE_UDID=$1
TEST_APP_NAME=$2
JAVASCRIPT_TEST_FILE=$3
BASE_TEST_SCRIPTS_PATH=$4
TEST_RESULTS_OUTPUT_PATH=$5



# ===== FUNCTIONS =====

main() {
    _save_and_clear_internal_field_separator

    if [ ${DEBUG_MODE_ENABLED} -eq 1 ]; then
        echo "main(): Launched script" $0
    fi

    # Determine the UDID of the simulator we are to use. With Xcode 6.0.1, you can name the simulators as you wish,
    # and they are all given UDIDs that form part of the file path to get to the .app. We can read the device.plist
    # file instead each simulator directory, to figure out which one is ours.
    local simulator_path=`_find_specific_simulator ${BASE_SIMULATORS_PATH} ${SIMULATOR_NAME_OR_DEVICE_UDID}`

    if [ ${DEBUG_MODE_ENABLED} -eq 1 ]; then
        echo "main(): Just searched for simulator_path and got this result:" ${simulator_path}
    fi

    if [ ${simulator_path} == "Simulator Not Found" ]; then
        echo "main(): Couldn't find a simulator with name '"${SIMULATOR_NAME_OR_DEVICE_UDID}"'. Using this as a device UDID instead"
        simulator_path=${SIMULATOR_NAME_OR_DEVICE_UDID}
    fi

    # We're now calling the function that runs the actual instruments command:
    _run_automation_instrument ${TEST_APP_NAME} \
        ${BASE_TEST_SCRIPTS_PATH} \
        ${JAVASCRIPT_TEST_FILE} \
        ${simulator_path} \
        ${SIMULATOR_NAME_OR_DEVICE_UDID} \
        ${TEST_RESULTS_OUTPUT_PATH}

    _restore_prior_interal_field_separator
}


# Allow us to use spaces in quoted file names in Bash Shell,
# per http://stackoverflow.com/a/1724065/535054 (See Dennis Williamson's comment):
_save_and_clear_internal_field_separator() {
    saveIFS="$IFS"; IFS='';
}


# Revert to the pre-existing IFS shell variable value so as not to leave shell with unintended side effects.
_restore_prior_interal_field_separator() {
    IFS="$saveIFS"
}


# _find_app_path_navigating_changing_guid
# Created by @idStar - Sohail Ahmed
# This script finds the guid for a given iOS simulator app. Use in a pipe to get the full path
#
# Usage:
# 	find_app_guid <"Simulator Path"> <"App Name.app">
#
# The Simulator Path should be something like: "$HOME/Library/Developer/CoreSimulator/Devices/05BB8391-CCB5-47D8-952E-BA3AF342C891"
# It is basically some parent folder under which recursive traversal would eventually find the app sought.
# The App Name should include the .app suffix. It should already be built for the simulator, in order for us to find it.
_find_app_path_navigating_changing_guid() {
    # Retrieve parameters:
    local specific_simulator_path=$1
    local test_app_name=$2

    cd ${specific_simulator_path}

    # Find the fully qualified path:
    local full_app_path=`find ${specific_simulator_path} -name ${test_app_name}`

    # Return the answer with echo, to allow for piping commands:
    echo ${full_app_path}
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
    local base_simulators_path=$1  # The path that is the root of the various simulators that could be installed.
    local simulator_name=$2  # The custom simulator a user can give different simulator configurations, since the Xcode 6.0.1 iOS Simulator app

    # Construct the line we'll look for an exact match to in the plist file:
    local simulator_plist_line_to_match="<string>$simulator_name</string>"

    # Loop through all devices to figure out which is a match
    for DEVICE_DIRECTORY in ${base_simulators_path}/*; do
        # Retrieve the number of matches to our search string in the 'device.plist' file in the iterated simulator directory:
        local num_matches=$(grep "$simulator_plist_line_to_match" "$DEVICE_DIRECTORY"/device.plist | wc -l)

        # Did this directory return one match?
        if [ ${num_matches} -eq 1 ]; then
            # MATCHING_UDID=$(basename ${DEVICE_DIRECTORY})
            # Our return value is the full path of the matching simulator:
            local specific_simulator_path_found=${DEVICE_DIRECTORY}
            echo "$specific_simulator_path_found"
            return # We got what we came for; this confirms that we're going to use the simulator
        fi
    done

    echo "Simulator Not Found" # Signifies that no matching simulator could be found.
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
    # Reanimate command line parameters into properly named variables:
    local test_app_name=$1 # The first command line argument is a quoted string, containing the name of app we are to find in the iOS Simulator's dynamic list of app directories
    local base_automation_test_scripts_path=$2 #The second command line argument is a quoted string to the path where test scripts are stored, such as the one passed in as the next argument.
    local test_script_name=$3  # The third command line argument is a quoted string, containing the name of the JavaScript test file to run with Instruments' UIAutomation
    local specific_simulator_path=$4 # The fourth command line argument is a quoted string, containing the path to a folder under which iOS Simulator apps can be found
    local simulator_name_or_device_udid=$5 # The fifth argument is the custom name you've given to the simulator, per http://stackoverflow.com/a/24728406/535054
    local test_results_output_path=$6 # The sixth command line argument is a quoted string, containing the path to a directory in which UIAutomation test results should be placed

    if [ ${DEBUG_MODE_ENABLED} -eq 1 ]; then
        echo "_run_automation_instrument(): Received test_app_name:" ${test_app_name}
        echo "_run_automation_instrument(): Received base_automation_test_scripts_path:" ${base_automation_test_scripts_path}
        echo "_run_automation_instrument(): Received test_script_name:" ${test_script_name}
        echo "_run_automation_instrument(): Received specific_simulator_path:" ${specific_simulator_path}
        echo "_run_automation_instrument(): Received simulator_name_or_device_udid:" ${simulator_name_or_device_udid}
        echo "_run_automation_instrument(): Received test_results_output_path:" ${test_results_output_path}
    fi

    local fully_qualified_app_path_or_app_name_on_device=""

    # Were we passed the same value for the simulator name and the specific simulators path?
    if [ ${specific_simulator_path} == ${simulator_name_or_device_udid} ]; then
        # YES. That's code for "there is no matchin simulator". Therefore, we'll treat this as a device UDID.
        echo "_run_automation_instrument(): Interpreting '"${simulator_name_or_device_udid}"' as a device UDID to be run on."
        fully_qualified_app_path_or_app_name_on_device=${test_app_name}
    else
        # NO. We received a distinct value for the specific simulator path, which means we should proceed hunting
        # through that path's child folders for the matching app:
        fully_qualified_app_path_or_app_name_on_device=`_find_app_path_navigating_changing_guid ${specific_simulator_path} ${test_app_name}`
    fi


    local automation_test_script_path="$base_automation_test_scripts_path/$test_script_name"

    # Switch directory into the output directly, b/c otherwise, occasionally,
    # Instruments will dump a .trace file in the directory from which this script is launched.
    cd ${test_results_output_path}

    # Invoke the actual instruments command line tool from Apple:
    instruments -t ${INSTRUMENTS_AUTOMATION_TEMPLATE_PATH} \
                -w ${simulator_name_or_device_udid} \
                ${fully_qualified_app_path_or_app_name_on_device} \
                -e UIASCRIPT ${automation_test_script_path} \
                -e UIARESULTSPATH ${test_results_output_path}
}



# ===== KICKING IT ALL OFF =====

main # Runs this script


