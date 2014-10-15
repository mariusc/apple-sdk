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

The framework can be obtained by:

* downloading the binary `.framework` file for iOS or OSX (this will be updated once the code to generate "multiplatform" frameworks is implemented on the project) :)

*or*

* generating the binary `.framework` file from this Xcode project. Just select the platform you want from the project's targets and click *build* (⌘+B).

  ![Generating the framework file](./README/Assets/BuildProcess01.gif)

### Using the Framework

The framework can be used in two different manners:

* Dragging and Dropping the Framework

  Drag & Drop the `.framework` file onto your project and make sure that the framework appears both in *Embedded Binaries* and in *Linked Frameworks and Libraries*;

  ![Drag & Drop the framework](./README/Assets/BuildProcess02.gif)

* Using the Framework as a Sub-Project:

  Drag & Drop the `Relayr.xcodeproj` onto your project and add the *Relayr* project product as *Embedded Binaries* (and therefore also *Linked Frameworks and Libraries*).

  ![Use as subproject](./README/Assets/BuildProcess03.gif)

Basic Classes
-------------

The `Relayr.framework` includes a small subset of useful classes, which allow you to communicate with the relayr cloud, receive sensor data and manage users, devices transmitters and other entities. At the moment The BLE Direct Connection Classes are not fully implemented but they should be available in upcoming releases. The classes indicated below are all related to App > Cloud > Device communication.  
All calls are asynchronous and the server response time is proportional to the quality of your connection and the size of the response requested.

### *RelayrCloud*

Used as a static class to receive various statuses from the relayr servers.

```objective-c
[RelayrCloud isReachable:^(NSError* error, NSNumber* isReachable){
    if (isReachable.boolValue) {
        NSLog(@"The Relayr Cloud is reachable!");
    }
}];

[RelayrCloud isUserWithEmail:@"marcos@relayr.de" registered:^(NSError* error, NSNumber* isUserRegistered) {
    if (!error && isUserRegistered.boolValue) {
        NSLog(@"The user is registered on the platform");
    }
}]
```

### *RelayrApp*

A representation of your iOS/OSX app on the relayr [Cloud Platform](https://developer.relayr.io/documents/Welcome/Platform). This object is required in order to interact with the Relayr services (it is worth noticing that this is not a singleton and theoretically, you can define as many relayr apps as you wish).

An instance of `RelayrApp` can be created by passing the credentials (*appID*, *OAuthClientSecret*, and *redirectURI*) obtained from the [Developer Dashboard](https://developer.relayr.io/dashboard/apps/myApps), when you define the application to use the relayr Cloud Platform.

```objective-c
[RelayrApp appWithID:@"..." OAuthClientSecret:@"..." redirectURI:@"..." completion:^(NSError* error, RelayrApp* app){
    if (app) {
        NSLog(@"Application with name: %@ and description: %@" app.name, app.description);
        self.app = app;
    }
}];
```

You can check your app's properties, query the server for information related to it, or sign users in and out of it. You can have as many logged in users as you want.

```objective-c
RelayrApp* app = ...;
[app signInUser:^(NSError* error, RelayrUser* user){
    if (user) {
        NSLog(@"User logged with name: %@ and email: %@", user.name, user.email);
    }
}];
```

Storing users isn't necessary, since they are stored within the `RelayrApp` instance. You can query the app for logged users by initiating this method:

```objective-c
RelayrUser* user = app.loggedUsers.lastObject;
// Or...
RelayrUser* user = [app loggedUserWithRelayrID:@"..."];
```

### *RelayrUser*

Represents a logged-in user. Users can access device data, they can query transmitters/devices they own, bookmark favorite devices, and become app publishers.

```objective-c
RelayrUser* user = ...;
NSLog(@"User with name: %@ and email: %@", user.name, user.email);

// Lets ask the cloud for all the transmitters/devices own by this specific user.
[user queryCloudForIoTs:^(NSError* error){
    if (error) { return NSLog(@"%@", error.localizedDescription); }

    for (RelayrTransmitter* transmitter in user.transmitters)
    {
        NSLog(@"Transmitter's name: %@", transmitter.name);
    }

    for (RelayrDevice* devices in user.devices)
    {
        NSLog(@"Device's name: %@", devices.name);
    }
}];
```

### *RelayrTransmitter*

An instance representing a *Transmitter*. A transmitter is one of the basic Relayr entities. A transmitter, contrary to a device, does not gather data but is only used to *relay* the data from the devices to the relayr cloud platform. The transmitter is also used to authenticate the different devices that transmit data via it.

In the case of the Relayr WunderBar, the transmitter is the Master Module in the Cloud Platform scenario (data being sent from the sensors by the Master Module to the Relayr cloud over MQTT/SSL). In the future case of direct connection an app running on your phone could serve as a transmitter.

```objective-c
RelayrTransmitter* transmitter = user.transmitters.anyObject;
NSLog(@"This transmitter relays information of %lu devices", transmitter.devices.count);
for (RelayrDevice* device in transmitter.devices)
{
    NSLog(@"Device name: %@, capable of measuring %lu different values", device.name, device.inputs.count);
}
```

### *RelayrDevice*

An instance representing a *Device*. A device is another basic relayr entity. A device is any external entity capable of producing measurements and sending them to a transmitter to be further sent to the relayr platform, or one which is capable of receiving information from the relayr platform.
Since a single relayr device can produce more than one reading at the same time, you should always query device capabilities prior to executing any other commands.

```objective-c
RelayrDevice* device = transmitter.devices.anyObject;
NSLog(@"Device manufacturer: %@ and model name: %@", device.manufacturer, device.modelName);

for (RelayrInput* reading in device.inputs)
{
    NSLog(@"This device can measure %@ in %@ units", reading.meaning, reading.unit);
    NSLog(@"Last value obtained by this device for this specific reading is %@ at %@", input.value, input.date);
}
```

The most reliable way to obtain data is to subscribe to a reading/input of a relayr device:

```objective-c
// You can choose to subscribe with a block (it will be executed every time a new value is received):
[device.inputs.anyObject subscribeWithBlock:^(RelayrDevice* device, RelayrInput* input, BOOL* unsubscribe){
    NSLog(@"Value received: %@ from device: %@", input.value, device.name);
    if (/* Many values have been read */) { *unsubscribe = YES; }
} error:^(NSError* error){
    NSLog(@"Some error happened while subscribing, please try again or blame PubNub for everything...");
}];

// Or you can choose to receive subscription values by target-action mechanism:
[device.inputs.anyObject subscribeWithTarget:self action:@selector(dataReceivedFrom:) error:^(NSError* error){
    NSLog(@"An error occurred while subscribing");
}];

- (void)dataReceivedFrom:(RelayrInput*)input
{
    NSLog(@"Value received: %@", input.value);
}
```

### *RelayrInput*, *RelayrOutput*, and *RelayrConnection*

These are object abstractions of a device's inputs and outputs, and a connection either to a transmitter or a different element on the platform.

You can query their properties for the following information:

* `RelayrInput` ***for data received from the device***. The type of data received is listed as a `meaning` and is measured in `unit` units.

  ```objective-c
  RelayrDevice* device = ...;
  for (RelayrInput* input in device.inputs)
  {
      NSLog(@"The measurement for %@ is: %@", input.meaning, input.value);
  }
  ```

* `RelayrOutput` ***for signals that the device can receive***. It can be infrared, or Grove signals.

  ```objective-c
  RelayrDevice* device = ...;
  for (RelayrOutput* output in device.outputs)
  {
      NSLog(@"");
  }
  ```

* `RelayrConnection` to query the connection state (connected, disconnected, resetting, etc.), and the connection type (BLE, Wifi, etc.). You can even subscribe to changes in the connection channel (for example, be informed when you are in close proximity to a device or when the WiFi connection of your device is interrupted).

The `RelayrConnection` and `RelayrOutput` have not yet been implemented. These are currently being implemented and will be availbled in an upcoming release.
