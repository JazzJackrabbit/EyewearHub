# Eyewear Hub

A MacOS utility that allows connecting to a J!NS MEME Academic device, reading raw live data from it and streaming it via UDP.

# Download

[Get latest version 📥 ]( https://github.com/JazzJackrabbit/EyewearHub/releases/download/albatros/Eyewear.Hub.zip )

Output format is a string with comma-separated numeric values: 

*AccX, AccY, AccZ, Roll, Pitch, Yaw, Right, Left* (default) 
*AccX, AccY, AccZ, Roll, Pitch, Yaw, **Vv**, **Vh*** (processed data)

## Contribute

This project uses CocoaPods. Install external plugins before building the project.
```
git clone git@github.com:JazzJackrabbit/EyewearHub.git
cd EyewearHub
pod install
open Eyewear\ Hub.xcworkspace
```
