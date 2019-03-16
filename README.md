# paranoid-ghidra

## Installation
1. [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
2. Make Digital Ocean API token available to Terraform
    ```bash
    export DIGITALOCEAN_TOKEN=insertokenhere
    ```
3. **[OPTIONAL]** Capture more verbose Terraform logging:
    ```bash
    export TF_LOG=TRACE
    export TF_LOG_PATH=$PWD/terraform.log
    ```
4. Modify variables in `terraform.tfvars` file
5. Initialize Terraform (e.g., download necessary plugins)
    ```bash
    terraform init
    ```
6. Output what will happen when you run `terraform apply`
    ```bash
    terraform plan
    ```
7. Deploy Droplet (execute plan)
    ```bash
    terraform apply
    ```
8. Run SSH port forward command (`connect_cmd` from `terraform output`)
9. Download [TightVNC](https://www.tightvnc.com/download.php) and *only* select TightVNC Viewer (VNC client)
10. Connect to `localhost:5901` using TightVNC Viewer and randomly generated VNC password (`vnc_pass` from `terraform output`)
11. If the desktop session displays a gray screen (see [Issues](#issues)), use `start_vnc` commands from `terraform output` 

## Why?
For those who need a template for running software like ghidra on anything that's *not* your machine.

## How?
Through the magic of Terraform and VPS providers (in this case, Digital Ocean)

## Issues
* For some reason, provisioning the bootstrap shell script via Terraform doesn't properly initialize and configure the VNC session. Connecting to it results in an unusable desktop session (gray screen). Manually SCP'ing and executing the bootstrap script directly on the Droplet works just fine. I've attempted to resolve this by (1) provisioning an expect script and (2) providing the bootstrap script as userdata (commands to execute during Droplet initialization), but both of these approaches failed. To account for this, I've added a few commands as an output (`start_vnc`) that can be executed by the user to kill and restart the VNC server. 

## Pro-Tips
* `Ctrl+Alt+Shift+F` to exit full-screen mode in TightVNC client/viewer

## TO-DO
* Need to provide variable that determines (either automatically or via user input) the desired VNC session resolution and feed that into `-geometry` flag for `vncserver`