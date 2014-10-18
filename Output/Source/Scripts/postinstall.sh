#!/bin/bash

mkdir -p "${HOME}"/Library/Mail/Bundles
mv /tmp/AveNoAnimationsInMailPlugin.mailbundle "${HOME}"/Library/Mail/Bundles/
chown -f -R "${USER}":staff "${HOME}"/Library/Mail/Bundles/AveNoAnimationsInMailPlugin.mailbundle

exit 0