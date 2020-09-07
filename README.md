# Sendbird Calls for iOS Quickstart
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/sendbird/quickstart-calls-ios/blob/develop/LICENSE.md)

[![Download:
AppStore](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/gb/app/id1503477603)

## Introduction

Sendbird Calls SDK for iOS is used to initialize, configure, and build voice and video calling functionality into a Sendbird iOS application. In this repository, you will find the steps you need to take before implementing the Calls SDK into a project, and a sample application which contains the framework for implementing voice and video call. 

### More about Sendbird Calls for iOS

Find out more about Sendbird Calls for iOS on [Calls for iOS doc](https://docs.sendbird.com/ios/calls_quick_start). If you need any help in resolving any issues or have questions, visit [our community](https://community.sendbird.com).

<br />

## Before getting started

This section shows you the prerequisites you need for testing Sendbird Calls for iOS sample app.

### Prerequisites

The minimum requirements for Calls SDK for iOS sample are: 

- Mac OS with developer mode enabled
- Xcode
- [Git Large File Storage](https://git-lfs.github.com/)
- Homebrew
- At least one physical iOS device running iOS 9.0 and later 
- Swift 4.0 and later

### Environement Setup

Installing the Calls SDK is simple if you’re familiar with using external libraries or SDK’s in your projects. After creating your Sendbird application from your dashboard, install **Git Large File Storage (LFS)**, then you can choose to install the Calls SDK using either **CocoaPods** or **Carthage**.

### Step 1. Install Git LFS
 
To download `SendBirdWebRTC`, Git LFS **MUST** be installed by running the following command

To use Sendbird Calls, you should first add our custom-built `SendBirdWebRTC` to your project. **Git LFS** must be installed to use the `WebRTC`. To download **Git LFS**, run the following command on your terminal window.

```bash
$ brew install git-lfs
```

For further details, refer to [https://git-lfs.github.com](https://git-lfs.github.com)
 
You can only integrate one Sendbird application per app for your service regardless of the platforms. All users within your Sendbird application can communicate with each other across all platforms. This means that your iOS, Android, and web client app users can all make and receive calls with one another without any further setup. Note that all data is limited to the scope of a single application, and users in different Sendbird applications can't make and receive calls to each other.
 
> Important: Make sure to install Git LFS before installing the pod. The size of `WebRTC.framework` in **SendBirdWebRTC** folder must be over 800 MB. If the size of the loaded `SendbirdWebRTC` framework is smaller than 800 MB, check the Git Large File Storage settings and download again. For further details, refer to SDK’s troubleshooting section. 
 
 
### Step 2. Install SDK via CocoaPods or Carthage

#### CocoaPods

Open a terminal window. Navigate to the project directory, and then open the `Podfile` by running the following command:

```bash
$ open Podfile
```

Make sure that the `Podfile` includes the following:

```bash
platform :ios, '9.0'
 
target 'Project' do
    use_frameworks!
    
    pod 'SendBirdCalls'
end
```

Install the `SendBirdCalls` framework via **CocoaPods**.

```bash
$ pod install
```

#### Carthage

You can also use **Carthage** to integrate the `SendBirdCalls` framework into your Xcode project.

1. Install Carthage into your project by running `brew install carthage` in your project directory or choose any of other installation options.
2. Create a `Cartfile` in the same directory where your **.xcodeproj** or **.xcworkspace** is.
3. Add `github “sendbird/sendbird-calls-ios”` and github `“sendbird/sendbird-webrtc-ios”` dependencies to your `Cartfile`.
4. Run carthage update.
5. A `Cartfile.resolved` file and a Carthage directory will appear in the same directory where your .xcodeproj or .xcworkspace is.
6. Drag the built **.framework** binaries from **Carthage/Build/iOS** into your application’s Xcode project.
7. On your application targets’ **Build Phases** settings tab, click the **+** icon and choose **New Run Script Phase**. Create a Run Script in which you specify your shell (ex: `/bin/sh`), add the following contents to the script area below the shell: `usr/local/bin/carthage copy-frameworks`
8. Add the paths to the frameworks you want to use under **Input Files**. For example:
```bash
$(SRCROOT)/Carthage/Build/iOS/SendBirdCalls.framework
```
```bash
$(SRCROOT)/Carthage/Build/iOS/WebRTC.framework
```
9. Add the paths to the copied frameworks to the **Output Files**. For example:
```bash
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SendBirdCalls.framework
```
```bash
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/WebRTC.framework
```
10. For more information, refer to the [Carthage’s guide](https://github.com/Carthage/Carthage#quick-start).


## Creating a SendBird application

 1. Login or Sign-up for an account at [dashboard](https://dashboard.sendbird.com).
 2. Create or select an application on the SendBird Dashboard.
 3. Note the `Application ID` for future reference.
 4. [Contact sales](https://sendbird.com/contact-sales) to get the `Calls` menu enabled in the dashboard. (Self-serve coming soon.)

## Creating test users

 1. In the SendBird dashboard, navigate to the `Users` menu.
 2. Create at least two new users, one that will be the `caller`, and one that will be the `callee`.
 3. Note the `User ID` of each user for future reference.


## Specifying the App ID
As shown below, the `SendBirdCall` instance must be initiated when a client app is launched. Initialization is done by setting the `APP_ID` of the SendBird application in the dashboard. This **App ID** of the SendBird application must be specified inside the sample application’s source code.

Find the `application(_:didFinishLaunchingWithOptions:)` method from `AppDelegate.swift`. Replace `YOUR_APP_ID` with the `App ID` of the SendBird application created previously.
 
```Swift
SendBirdCall.configure("YOUR_APP_ID")
```
 
## Installing and running the sample application

 1. Verify that Xcode open on the development Mac and the sample application project is open
 2. Plug the primary iOS device into the Mac running Xcode
 3. Unlock the iOS device 
 4. Run the application by pressing the **`▶`** Run button or typing `⌘+R`
 5. Open the newly installed app on the iOS device
 6. If two iOS devices are available, repeat these steps to install the sample application on both the primary device and the secondary device.

## Registering push tokens
In order to make and receive calls, authenticate the user with SendBird server with the `SendBirdCall.authenticate(with:)` method and **register a VoIP push token** to SendBird. Register a VoIP push token during authentication by either providing it as a parameter in the `authenticate()` method, or after authentication has completed using the `SendBirdCall.registerVoIPPush(token:)` method. VoIP Push Notification will also enable receiving calls even when the app is in the background or terminated state. A valid VoIP Services certificate or Apple Push Notification Service certificate also needs to be registered on the `SendBird Dashboard` : `Application` → `Settings` → `Notifications` → `Add certificate`.

For more details about generating certificates, see this guide: [How to Generate a Certificate for VoIP Push Notification](https://github.com/sendbird/guidelines-ios/tree/master/How%20to%20generate%20iOS%20certificate)

To handle a native-implementation of receiving incoming calls, implement Apple’s [PushKit framework](https://developer.apple.com/documentation/pushkit) and CallKit. This is done by registering the push tokens associated with the SendBird Applications and handling appropriate events. For more information refer to Apple’s [Voice Over IP (VoIP) Best Practices
](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html)

For more details about using CallKit framework, see this guide: [How to develop VoIP app with CallKit](https://github.com/sendbird/guidelines-ios/tree/master/How%20to%20develop%20VoIP%20app%20with%20CallKit)

## Making calls

 1. Log in to the primary device’s sample application with the ID of the user designated as the `caller`.
 2. Log in to the secondary device’s sample application with ID of the user designated as the `callee`.  Alternatively, use the Calls widget found on the Calls dashboard to login as the `callee`.
 3. On the primary device, specify the user ID of the `callee` and initiate a call.
 4. If all steps have been followed correctly, an incoming call notification will appear on the `callee` user’s device.
 5. Reverse roles, and initiate a call from the other device.
 6. If the `caller` and `callee` devices are near each other, use headphones to prevent audio feedback.

# Advanced

## Handling Incoming Calls without Media Permission
When using CallKit to process your calls, there may be instances where the user has not granted media(audio/video) permissions. Without the necessary permissions, the call will proceed without audio and/or video, which can be critical to the user experience. Some other third-party apps implement different user flow to prevent the call from starting without according media permissions. However, due to CallKit requiring new incoming calls to be reported to CallKit immediately, there are some issues in implementing such change. Here is our solution:

We need to make sure that our PushKit usage is in sync with the device's media permission state. If media permissions are not granted, we should destroy existing push token to stop receiving VoIP Push and ignore any incoming calls. 

> Note, however, Apple's requires every VoIP Push Notifications to report a new incoming call to CallKit as writte in [Apple's Documentation](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/2875784-pushregistry). Be sure to test your implementation and refer to Apple's [guidelines](https://developer.apple.com/documentation/pushkit/responding_to_voip_notifications_from_pushkit) on VoIP Push Notifications and CallKit. 

In your AppDelegate's `pushRegistry(_:didReceiveIncomingPushWith:for:completion:)`, add the following: 
```swift
guard AVAudioSession.sharedInstance().recordPermission == .granted else { // Here, we check if the audio permission is granted
  // If it is not granted, we will destroy current push registration to stop receiving push notifications
  self.voipRegistry?.desiredPushTypes = nil
  
  // We will ignore current call and not present a new CallKit view. This will not cause crashes as we have destroyed current PushKit usage.
  completion()
  return
}

// Media permissions are granted, we will process the incoming call. 
SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
  ...
```
This will ignore incoming call if the media permissions are not granted, and prevent any future calls from being delivered to the device. 


In your AppDelegate's `application(_:didFinishLaunchingWithOptions:)`, you may also want to register VoIP Push Notification only if the media permissions are granted.
```swift
if AVAudioSession.sharedInstance().recordPermission == .granted {
  self.voipRegistration()
}
```

Note, however, destroying existing PKPushRegistry will prevent any future VoIP Push Notifications to be sent to the device. If you want to start receiving VoIP Push Notifications again, you must re-register PKPushRegistry by doing `self.voipRegistry?.desiredPushTypes = [.voIP]`.

## Creating a Local Video View Before Accepting Incoming Calls  

You can create current user's local video view and customize its appearance before accepting an incoming call. Customize the current user’s local video view by following the steps below:

1. Add a `UIView` to your storyboard.
2. Create a view with the frame you want by using the `SendBirdVideoView` object.
3. To add a subview, [embed](https://github.com/sendbird/quickstart-calls-ios/blob/develop/QuickStart/Extensions/UIKit/UIView%2BExtension.swift) the `SendBirdVideoView` to the `UIView` from Step 1.
4. Find an appropriate camera device by accessing the `availableVideoDevice` property of `DirectCall`.
5. Start capturing video contents from the camera by calling the `DirectCall.selectVideoDevice(_:completionHandler:)` method.

```SWift
@IBOutlet weak var localVideoView: UIView?

// Create SendBirdVideoView
let localSBVideoView = SendBirdVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)

// Embed the SendBirdVideoView to UIView
self.localVideoView?.embed(localSBVideoView)

// Start rendering local video view
guard let frontCamera = (call.availableVideoDevice.first { $0.position == .front }) else { return }
call.selectVideoDevice(frontCamera) { (error) in
    // handle error
}
```

## Allowing only one call at a time

Currently Sendbird Calls only supports a one-to-one call and the call waiting feature isn’t available yet. Using the `SendBirdCall.getOngoingCallCount()` method, you can retrieve the number of the current user’s ongoing calls and end a call if the call count has reached its limit.

```swift
if SendBirdCall.getOngoingCallCount() > 1 {
    call.end()
}
```

If you’re using Apple’s CallKit framework, you should use `CXProviderConfiguration` instead to set the allowed number of the current user’s ongoing calls as shown below:

```swift
let configuration = CXProviderConfiguration(localizedName: "Application Name")
configuration.maximumCallsPerCallGroup = 1
configuration.maximumCallGroups = 1
...
let provider = CXProvider(configuration: configuration)
```

## Reference

 - [SendBird Calls iOS SDK Readme](https://github.com/sendbird/sendbird-calls-ios/blob/master/README.md)
