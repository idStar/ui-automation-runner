# Overview

**UI Automation Runner** is a script borne out of frustration wanting to run UIAutomation tests from the command line.

Perhaps like me, you found many other tools that attempt to simplify this that fall into one or more of the following camps:
 
 1. They're out of date. This happens frequently when a new Xcode version is released, like I found with Xcode 6. 
 2. They are difficult to understand (the idea being to contribute fixes). This can be b/c of poor documentation, abandonment, etc.
 3. They are often wrapped up in trying to do a whole lot more than just run the instruments automation template with a script.

You may ask:
> Doesn't Apple give us a command line tool called `instruments` that we can use?

Indeed they do. And this project's key script invokes that command line tool from Apple. 

However, Apple's `instruments` script won't find your app's simulator location for you. It won't resolve the full path to your app within the appropriate simulator for you.

Furthermore, when you clean your build folders or reconfigure your simulators, guess what? All of those UDID strings that form part of the path to get to your app install, change.

The `ui_automation_runner.sh` script has built-in intelligence (like some other tools/projects that have come before it), which determines and resolves all of these paths for you.

Furthermore, the location for the Automation Instrument template is clearly marked at the top of the file. Assuming Apple's changes are minor over future Xcode releases, this nimble script should be easy to update.

## Usage

1. Take the companion `run_tests.example.sh` file and make a copy entitled `run_tests.sh`.
2. Edit the values in this **run_tests** script, by following the comments within that script file. The documentation in that file will explain how to configure each variable.
3. Invoke your modified `run_tests.sh` file in the terminal, and watch it make UIAutomation go!

Personally, I like to symlink in the ui-automation-runner local repository into my Xcode project's workspace, into a dedicated _MyAppUIAutomationTests_ directory, where I also keep all of my UIAutomation JavaScript test files.

All of the pathing in the scripts should be intelligent enough that you can run them from anywhere on the filesystem, since you lay the groundwork for all path-resolution in the `run_tests.sh` file.
  
You may want to create a variant of `run_tests.sh` for each of your projects that have UIAutomation tests, and keep them co-located in this folder, along with the `ui_automation_runner.sh` script that they rely on.

### Output

At the terminal, running the script will echo back for you, what the actual underlying instruments command constructed was. 

# Future Updates 

When future Xcode changes inevitably break this script, some things to look at in the `ui_automation_runner.sh` script, will be the following:

1. **INSTRUMENTS_AUTOMATION_TEMPLATE_PATH**: Update this to the path that Apple now has for the Automation Instrument.
2. **BASE_SIMULATORS_PATH**: Update this to the path that Apple now installs simulators that you can configure.

### Current Version

The current version has been tested to work with Xcode 6.0.1.

# Limitations

This script is not meant to be the kitchen sink, but it is meant to be easy to maintain by others who stumble upon it. As such, there are lots that this script does not pretend to do. This list includes:

1. **Building your app target** before running tests against it. If you don't already have it successfully built and installed on your simulator/device, this script won't help you do that.
2. Returning **proper unix exit codes**. [Jonathan Penn](https://twitter.com/jonathanpenn) does some great work in that regard, which is demonstrated in his handy utility [ui-screen-shooter](https://github.com/jonathanpenn/ui-screen-shooter).
3. Returning **robust error messages** for various types of failures. There's some attempt at this, but flow control in BASH scripts with functions is messy. Re-writing this script in Ruby is an exercise for the reader or the author at some mythical future time with more time! :)


# Contact

Best place to reach me is on Twitter. I don't imagine there would be too much discussion around these couple of scripts. If you've had to make corrections to get things to work, certainly, that would be handy to know.

-- Sohail 

* blog: [sohail.io](http://sohail.io)
* twitter: [@idStar](https://twitter.com/idStar)
* app.net: [@sohail](https://alpha.app.net/sohail)


# License

UI Automation Runner is available under the MIT license. See the LICENSE file for more info.
