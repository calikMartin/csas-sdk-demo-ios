# CSAS SDK Demo for iOS

This repository contains demo application demonstrating the usage of iOS SDKs by Ceska Sporitelna a.s.

## SDKs being showcased

- [x] **[CoreSDK](https://github.com/Ceskasporitelna/cs-core-sdk-ios)** - Configuration of CoreSDK
- [x] **[CoreSDK/Locker](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/docs/locker.md)** - Configuration of Locker & Event handling
- [x] **[LockerUI](https://github.com/Ceskasporitelna/cs-locker-ui-sdk-ios)**  - LockerUI configuration and sample flow
- [x] **[Uniforms](https://github.com/Ceskasporitelna/cs-uniforms-sdk-ios)** - Uniforms configuration and sample flow
- [x] **[Netbanking](https://github.com/Ceskasporitelna/cs-netbanking-sdk-ios)** - Easy and safe access to client acconts, products and transaction history
- [x] **[TranspaprenAcc](https://github.com/Ceskasporitelna/cs-transparent-acc-sdk-ios)**  - Transparent accounts configuraton and sample flow
- [x] **[AppMenu](https://github.com/Ceskasporitelna/cs-appmenu-sdk-ios)** - AppMenu - listing applications of  Česká spořitelna a.s, checking for version of app
- [x] **[Places](https://github.com/Ceskasporitelna/cs-places-sdk-ios)** - Places - list places of Česká spořitelna a.s.
# [Changelog](CHANGELOG.md)

# Requirements

- iOS 8.1+
- Xcode 8.3+


# Installation

1) Install latest version of [Carthage](https://github.com/Carthage/Carthage) and make sure you have recent version of `git`.

2) Clone this repository using command `git clone git@github.com:Ceskasporitelna/csas-sdk-demo-ios.git`

3) Enter into cloned directory using command `cd csas-sdk-demo-ios`.

4) Run command `carthage bootstrap --platform iOS` to download and set up dependencies and build schemes. This may take a minute or two and patience is the key to get everything working.

# Usage

## Running CSAS SDK Demo

To see how the demo application works, just open the project `CSSDKDemo.xcodeproj` in Xcode.

Implementation of the application is in group `CSSDKDemo`. Pay special attention to `AppDelegate.swift` and `MainViewController.swift` to see how the frameworks are configured and used.

To run the app in Simulator or on your hardware, simply run the scheme `CSSDKDemoApp`.

## Developing against CSAS SDK

All CSAS SDKs are included in this repositories as submodules, you can thus use this demo project to test your implementation of bugfixes and new features. Please use scheme `DevCoreSDKTestApp` for developement. This scheme re-builds all CSAS SDKs before running the application.

# Contributing

Contributions are more than welcome!

Please read our [contribution guide](CONTRIBUTING.md) to learn how to contribute to this project.

# Terms and License

Please read our [terms & conditions in license](LICENSE.md)
