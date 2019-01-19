#!/bin/bash

# run_tests.sh
# Created by Sohail A.
# @idStar

# This script is a companion to the script ui_automation_runner.sh, which is designed not to be edited.
# In this very script however, you'll actually modify some variables below to specify values for
# what you would like run, where to find your test, where to dump results, etc.


# ===== DEVICES AND SIMULATORS =====

# Define all of your simulators and devices here.

# Create descriptive variables to hold the UDIDs of your devices and the custom names of your simulators.
# If you're new to Xcode 6's custom simulators, read the following for more context:
# https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/iOS_Simulator_Guide/GettingStartedwithiOSStimulator/GettingStartedwithiOSStimulator.html
# Specifically, the section entitled, "Change the Simulated Device and iOS Version". In a nutshell, you can to choose
# which simulators are defined, and what they're called. The ui-automation-runner.sh script will use these names
# to find the right simulator to launch. We recommend creating a variable for each of your defined simulators here,
# so you can switch between them easily when providing a value to the 'SIMULATOR_NAME_OR_DEVICE_UDID' down below.

device_udid_iPhone5s_iOS8="f04d9cefeccf5013e3ce89db955e68d6ce1551c4" # Not my real device UDID, but you get the idea
simulator_iPhone6Plus_iOS8="iPhone 6 Plus"
simulator_iPad_Air_iOS8="iPad Air"
simulator_iPhone5s_iOS7_1="iPhone 5s (iOS7.1)"


# ===== REACHING THE TEST RUNNER =====

# You may choose to keep this app specific script co-located with your app, and your copy of the
# ui_automation_runner script in some other more generic location. Whatever you choose, that needs to be reflected
# as an absolute or relative path to the current file:
AUTOMATION_RUNNER_SCRIPT_PATH="./ui_automation_runner.sh"


# ===== YOUR APP AND TEST FILE SETTINGS =====

# The name of your app. Use your Xcode project name. This is not necessarily the icon display name visible in Springboard.
# Leave off the ".app" extension so that you can reference the same app name when switching between device and simulator.
TEST_APP_NAME="ACMERoadRunnerRadar"

# Set which simulator or device you want Instruments Automation to run with:
SIMULATOR_NAME_OR_DEVICE_UDID=${simulator_iPhone5s_iOS7_1}

# The directory in which we can find the test file you'll specify below:
JAVASCRIPT_TEST_FILES_DIRECTORY="$HOME/Developer/clients/acme/roadrunnerradar/ACMERoadRunnerRadarAutomationTests/"

# The JavaScript test file you'd like to run. For a suite of tests, have this file simply import and
# execute other JavaScript tests, so that you can conceivably run a full suite of tests with one command:
JAVASCRIPT_TEST_FILE="TestRunner.js"

# The directory into which the instruments command line tool should dump its verbose output:
TEST_RESULTS_OUTPUT_PATH="$HOME/Developer/clients/acme/roadrunnerradar/ACMERoadRunnerRadarAutomationTests/TestRuns/"



# ---------- DO NOT EDIT ANYTHING BELOW THIS LINE, UNLESS YOU KNOW WHAT YOU'RE DOING -----------

"$AUTOMATION_RUNNER_SCRIPT_PATH" \
    "$SIMULATOR_NAME_OR_DEVICE_UDID" \
    "$TEST_APP_NAME" \
    "$JAVASCRIPT_TEST_FILE" \
    "$JAVASCRIPT_TEST_FILES_DIRECTORY" \
    "$TEST_RESULTS_OUTPUT_PATH"
