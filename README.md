No Mail.app Animations on OS X 10.9 Mavericks
=============================================

A Mailbundle plugin to disable the Mail.app Send- and Reply-animations on OS X 10.9 Mavericks


How does it work?
================
This Plugin disables Mail.app animations in 10.9 by swizzling Mail.app's -[DocumentEditor shouldDoPopOutAnimation] to return NO always.
To disable the sent-animation, we swizzle -[DocumentEditor _performSendAnimation] to directly class -[DocumentEditor __sendAnimationCompleted]


How to Install?
===============
Store plugin bundle in ~/Library/Mail/Bundles/
and run 'defaults write com.apple.mail EnableBundles -int 1' in Terminal.app
