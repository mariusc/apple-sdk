Introduction
------------

Welcome to the relayr Apple SDK (*Beta*) repository.

This repository contains the code which allows you to build the Relayr Framework for iOS and OS X. The *RelayrSDK* project generates a product called `Relayr.framework` which, depending on your use purpose, can be run on a mac or on an iOS device.

The Relayr SDK requires:

* For iOS applications: Xcode 6+ and iOS 8+ (since the framework is released in the *Cocoa Touch Framework* form).
* For OSX applications: Xcode 5+ and OSX 10.9+.

Getting Started
---------------

### Obtaining the Framework

The framework can be obtained from several places:

* download the `.framework` file for the platform you are developing for from the latest [github release page](https://github.com/relayr/apple-sdk/releases/tag/v0.2.1).
* generate the `.framework` file from the source code.

  To generate the framework you need to perform the following steps:

  1. Download the repository from [GitHub](https://github.com/relayr/apple-sdk)
  2. Open the `Relayr.workspace` with Xcode.
  3. Select a specific target from the workspace's targets. If you are developing for iOS, select `Relayr_iOS`; and if you are developing for the mac, select `Relayr_OSX`.
  4. Select the platform for your target. For the mac, you will only have one choice (the mac); but for iOS, you can generate a framework for the simulator or for an iOS physical device.
  5. Edit the schema to select the type of build you want: Debug, Release, Distribution.
  6. Select `Product > Build` from the Xcode top menu (or press ⌘+B).
  7. Grab your `.framework` file from the created `/bin` folder on the workspace directory.

* make the `RelayrSDK` project a dependency of your build chain.

  This option is the most versatile; however, you need to know your way around XCode. The Relayr SDK will build its product in a separate folder; thus, you need not only add the framework as a target dependency, but also change your build settings to search for the framework on the `Build Settings` tab of your project.

### Using the Framework

To use the framework, just drag and drop the `.framework` file onto your project and make sure that the framework appears both in *Embedded Binaries* and in *Linked Frameworks and Libraries*;

  ![Drag & Drop the framework](./README/Assets/BuildProcess02.gif)

The default action when dragging and dropping a framework into your project is to simply *link* the framework, not add it to the final binary image. This won't work. You need to remove the framework from *Linked Frameworks and Libraries* and add it to the *Embedded Binaries* (which will automatically link the framework too).

Basic Classes
-------------

For a reference to the basic classes available in the SDK, please have a look at our [iOS/OSX documentation ](https://developer.relayr.io/documents/Apple/Classes)
