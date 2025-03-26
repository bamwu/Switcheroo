#!/bin/bash

case "$OS" in
    *[Ww][Ii][Nn][Dd][Oo][Ww][Ss]*)
        WINDOWS=true
        ;;
    *)
        WINDOWS=false
        ;;
esac

if [ "$WINDOWS" = true ]; then
    MACOS=false
	
    echo "This test project is macOS-specific..."
	return 0;
else
    MACOS=true
fi

SolutionDir=$(pwd)
ProjectDir="$SolutionDir/Switcheroo"
PublishDir="$SolutionDir/Publish"
SwitcherooVersion=$(sed -n 's:.*<Version>\(.*\)</Version>.*:\1:p' Switcheroo/Switcheroo.csproj)

# Validate and set script arguments
if [[ "$1" != "clean" && "$1" != "release" && "$1" != "debug" ]]; then
    echo "Error: First argument must be 'clean' or 'release' or 'debug'"
    exit 1
fi
SwitcherooVerb=$1

echo "SolutionDir: $SolutionDir"
echo "ProjectDir: $ProjectDir"
echo "SwitcherooVersion: $SwitcherooVersion"
echo "WINDOWS: $WINDOWS"
echo "MACOS: $MACOS"
echo "SwitcherooVerb: $SwitcherooVerb"

if [ "$MACOS" = true ]; then
	
	DeploymentGoodiesDir="$SolutionDir/Deployment/mac"
	Bundle="$PublishDir/Switcheroo.app"
	Contents="$Bundle/Contents"
	Resources="$Contents/Resources"
	Frameworks="$Contents/Frameworks"
	Library="$Contents/Library"
	CodeSignature="$Contents/_CodeSignature"
	MacOS="$Contents/MacOS"
	
	echo "Cleaning previous build and Switcheroo.app bundle..."
	
	if [[ "$SwitcherooVerb" == "release" ]]; then
		dotnet clean -c release
	elif [[ "$SwitcherooVerb" == "debug" ]]; then
		dotnet clean -c debug
	else
		dotnet clean -c debug
		dotnet clean -c release
	fi
	
	rm -rf "$SolutionDir/Publish/osx-arm64"
	rm -rf "$SolutionDir/Publish/osx-x64"
	rm -rf "$Bundle"
	
	if [[ "$SwitcherooVerb" == "clean" ]]; then
	    exit 0
	fi
	
    echo "Creating Switcheroo.app bundle..."
    
	mkdir -p "$Bundle/Contents/_CodeSignature"
    mkdir -p "$Bundle/Contents/Frameworks"
    mkdir -p "$Bundle/Contents/Library"
    mkdir -p "$Bundle/Contents/Resources"
    mkdir -p "$Bundle/Contents/MacOS"
	
    cp "$ProjectDir/Assets/Images/appicon-mac.icns"      "$Bundle/Contents/Resources/appicon-mac.icns"
    cp "$DeploymentGoodiesDir/Info.plist"                "$Bundle/Contents/Info.plist"
    cp "$DeploymentGoodiesDir/SwitcherooSwitcher"        "$Bundle/Contents//MacOS/Switcheroo"
	
	sed -i '' "s/SWITCHEROOVERSION/$SwitcherooVersion/g" "$Bundle/Contents/Info.plist"
	
	Architecture="arm64"
	RuntimeIdentifier="osx-$Architecture"
	OuterTargetDir="$SolutionDir/Publish/$RuntimeIdentifier"
	TargetDir="$OuterTargetDir/.build"

    echo "Building $RuntimeIdentifier..."
	dotnet publish -r $RuntimeIdentifier --configuration $SwitcherooVerb --self-contained -p:UseAppHost=true -o "$TargetDir"
	
    echo "Moving $RuntimeIdentifier build into bundle..."
    mv "$TargetDir" "$Bundle/Contents/MacOS/$Architecture"
	
	Architecture="x64"
	RuntimeIdentifier="osx-$Architecture"
	OuterTargetDir="$SolutionDir/Publish/$RuntimeIdentifier"
	TargetDir="$OuterTargetDir/.build"

    echo "Cleaning $RuntimeIdentifier..."
	rm -rf "$OuterTargetDir"
	
    echo "Building $RuntimeIdentifier..."
	dotnet publish -r $RuntimeIdentifier --configuration $SwitcherooVerb --self-contained -p:UseAppHost=true -o "$TargetDir"
	
    echo "Moving $RuntimeIdentifier build into bundle..."
    mv "$TargetDir" "$Bundle/Contents/MacOS/$Architecture"
	
	touch "$Bundle"
	
fi
