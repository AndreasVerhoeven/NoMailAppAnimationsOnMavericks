No Mail.app Animations on OS X 10.9 Mavericks, 10.10 Yosemite, 10.11 El Capitan, 10.12 Sierra, 10.13
=============================================================================================

A Mailbundle plugin to disable the Mail.app Send- and Reply-animations on OS X 10.9 Mavericks, OS X 10.10 Yosemite, OS X 10.11 El Capitan, macOS 10.12 Sierra, macOS 10.13.4. Run on your own risk. When having issues, please remove the 
Mailbundle again.


How does it work?
================
This Plugin disables Mail.app animations in 10.9 and 10.10 by swizzling Mail.app's -[DocumentEditor shouldDoPopOutAnimation] to return NO always.
To disable the send-animation, we swizzle -[DocumentEditor _performSendAnimation] to directly call -[DocumentEditor __sendAnimationCompleted]

On OS X 10.11 some other methods are swizzled to make the animation duration 0.0s, effectively disabling them. On macOS 10.12 Sierra one additional method is swizzled for this.


How to Install Automatically?
=============================

1. Download the installer from the Releases page
2. Option/right-click on the package and select Open with -> Installer.app 

How to Install Manually?
========================
1. Copy AveNoAnimationsInMailPlugin.mailbundle  to ~/Library/Mail/Bundles/
2. run 'defaults write com.apple.mail EnableBundles -int 1' in Terminal.app (without the quotes, of course)
3. Restart Mail.app



How to Build for new Mail versions?
===================================
1. Go to /Applications
2. Select Mail.app
3. Option/right-click and select 'Show Package Contents'
4. Go to Contents/Info.plist
5. Copy the value of the _PluginCompatibilityUUID_ key (e.g. 800E5C92-87D3-429B-8740-5C6183CD13EA)
6. Open the project in Xcode
7. Select the AveNoAnimationsInMailPlugin-Info.plist file
8. Add the UUID to the _Supported10.12PluginCompatibilityUUIDs_ key on macOS Sierra (older OSes: SupportedPluginCompatibilityUUIDs) list with a comment:

   Item 31 # For mail version 8.0 (1988) on OSX Version 10.10  
   Item 32 800E5C92-87D3-429B-8740-5C6183CD13EA
9. In Xcode: Product -> Build
10. In Xcode: Product -> Archive (this creates the installer package)
11. Commit to Github and send a Pull Request (highly appreciated)
