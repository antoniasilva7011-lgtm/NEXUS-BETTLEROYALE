# Android build automation — NEXUS

## Current state

The workflow `.github/workflows/build-android.yml` is added, but it will not run on GitHub's standard hosted runner. It requires a runner labeled `self-hosted`, `unreal`, and `android`, with the following environment variables:

- `UE_ROOT`: path to an installed and authorized Unreal Engine directory.
- `ANDROID_HOME`: Android SDK path configured for the selected Unreal version.
- `JAVA_HOME`: compatible JDK path.

The runner must also have the Android NDK and command-line tools configured in the way required by that Unreal Engine version.

## Why this is necessary

GitHub Actions can automate commands, but it does not include Unreal Engine or grant access to Epic's engine binaries by default. A normal `ubuntu-latest` runner cannot package this project unless the engine and Android toolchain are installed and authorized.

## Safe next step

Find a cloud runner provider that supports Unreal Engine licensing and Android packaging, or a permitted runner image with the engine already installed. Do not put Epic credentials, signing keys, or private engine files in this repository. For initial development, use an unsigned development APK if the build environment permits it.

## What success looks like

A successful run of **Package NEXUS for Android** produces an APK artifact named `NEXUS-Android-Development` or `NEXUS-Android-Shipping`. Until that workflow runs successfully, no APK should be considered available.
