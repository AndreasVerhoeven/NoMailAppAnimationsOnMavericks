#!/bin/bash

su -l "${USER}" -c "defaults write com.apple.mail EnableBundles -int 1"
rm -rf "${HOME}"/Library/Mail/Bundles/AveNoAnimationsInMailPlugin.mailbundle
rm -rf /tmp/AveNoAnimationsInMailPlugin.mailbundle

exit 0