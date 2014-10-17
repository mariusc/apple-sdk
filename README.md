Introduction
------------

Welcome to the relayr Apple SDK (*Beta*) repository.

This repository contains the code which allows you to build the Relayr Framework for iOS and Mac OS X. The *RelayrSDK* project generates a product called `Relayr.framework` which, depending on your use purpose, can be run on a mac or on an iOS device.

The Relayr SDK requires:

* For iOS applications: Xcode 6+ and iOS 8+ (since the framework is released in the *Cocoa Touch Framework* form).
* For OSX applications: Xcode 5+ and OSX 10.9+.

Getting Started
---------------

### Obtaining the Framework

The framework can be obtained in the following manner:


- Download the repository from [GitHub](https://github.com/relayr/apple-sdk)

- Generate the binary `.framework` file from this Xcode project. Just select the platform 	you want from the project's targets and click *build* (⌘+B).

  ![Generating the framework file](./assets/BuildProcess01.gif)

### Using the Framework

The framework can be used in two different manners:

#### 1. Dragging and Dropping the Framework

Drag & Drop the `.framework` file onto your project and make sure that the framework appears both in *Embedded Binaries* and in *Linked Frameworks and Libraries*; 

  ![Drag & Drop the framework](./assets/BuildProcess02.gif)

#### 2. Using the Framework as a Sub-Project:

* Drag & Drop the `Relayr.xcodeproj` onto your project and add the *Relayr* project product as *Embedded Binaries* (and therefore also *Linked Frameworks and Libraries*).

  ![Use as subproject](./assets/BuildProcess03.gif)

Basic Classes
-------------

For a reference to the basic classes available in the SDK, please have a look at our [iOS/OSX documentation ](https://developer.relayr.io/documents/Apple/Classes)
