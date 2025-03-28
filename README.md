# Switcheroo

This project is to demonstrate a problem with trying to package multiple builds for different cpu architectures in the same macOS .app bundle.

We are attempting to place the entire x64 and arm64 build folders inside the MacOS folder in the bundle and then use a script as a stand-in for the actual executable to detect the architecture and launch the actual, cpu-specific executable in the appropriate subfolder.

When launched directly from the terminal -- /path/to/Switcheroo/Publish/Switcheroo.app/Contents/MacOS/Switcheroo -- it runs fine.

It displays 2 things: the architecture and a message from a file on your desktop called switcheroo-message.txt.

Same thing for skipping the script entirely...

/path/to/Switcheroo/Publish/Switcheroo.app/Contents/MacOS/arm64/Switcheroo
/path/to/Switcheroo/Publish/Switcheroo.app/Contents/MacOS/x64/Switcheroo

However, when double-clicked in the finder, an exception is thrown when the app tries to read that file.

I catch the exception and show only its name in the app window, but this is the full message:

"System.UnauthorizedAccessException: Access to the path '/Users/myuser/Desktop/switcheroo-message.txt' is denied"

This project is managed in Rider, but I don't think that matters for the purposes of this test.

Please use the build.sh script from a terminal window while cd'd into the root directory of the solution.

The script builds the app for both architectures, then packages them along with the other boilerplate files in an .app bundle in the Publish directory inside the solution root directory.

To run the script:

./build.sh debug

or 

./build.sh release

It doesn't matter which, since the issue happens either way.

So, the big questions are: why am I getting this error when we launch the app in this manner and what can we do to get this working?
