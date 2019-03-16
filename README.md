# paranoid-ghidra

## Why?
For those who need a template for running software like ghidra on anything that's *not* your machine.

## How?
* Through the magic of Terraform and VPS providers (in this case, Digital Ocean)

## Issues
* For some reason, provisioning the bootstrap shell script via Terraform doesn't properly initialize and configure the VNC session. Connecting to it results in an unusable desktop session (gray screen). Manually SCP'ing and executing the bootstrap script directly on the Droplet works just fine. To account for this, I've added a few commands as an output (`start_vnc`) that can be executed by the user to kill and restart the VNC server.

## Pro-Tips
* `Ctrl+Alt+Shift+F` to exit full-screen mode in TightVNC client/viewer

## TO-DO
* Need to provide variable that determines (either automatically or via user input) the desired VNC session resolution and feed that into `-geometry` flag for `vncserver`