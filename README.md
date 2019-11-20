# Smart Eyewear Hub

This repository contains the MacOS utility that connects to a J!NS MEME Academic device, reads live data from it and streams it to localhost via UDP.

Any other application that relies on the data from J!NS MEME can be launched in parallel and read that data via UDP client. Current stream format is a string containing raw Integer numbers: **AccX,AccY,AccZ,Roll,Pitch,Yaw,Right,Left**

## Plugins

This project uses CocoaPods. Install external plugins before building the project.
```
pod install
```

## Contact

If you have any questions, please contact Kirill at ragozinkirill@gmail.com
