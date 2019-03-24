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
11. If, for some reason, the VNC session is not working as expected, simply restart the `runvnc` service on the Droplet:
    ```bash
    # SSH into Droplet using generated private key and IP address:
    # ssh -i <private_key> root@<droplet_ip>
    systemctl stop runvnc
    systemctl start runvnc
    ```

## Why?
For those who need a template for running software like ghidra on anything that's *not* your machine.

## How?
Through the magic of Terraform and VPS providers (in this case, Digital Ocean)

## Issues
For some reason, provisioning the original bootstrap shell script via Terraform doesn't properly initialize and configure the VNC session. Connecting to it results in an unusable desktop session (gray screen). Manually SCP'ing and executing the bootstrap script directly on the Droplet works just fine. I've attempted to resolve this by:

1. Provisioning an `expect` script; and
2. Providing the bootstrap script as userdata (commands to execute during Droplet initialization)

Unfortunately, both of these approaches failed. To account for this, I've automated the creation of a `systemd` service to facilitate management of `vncserver`. 

## Pro-Tips
* `Ctrl+Alt+Shift+F` to enter/exit full-screen mode in TightVNC Viewer

## TO-DO
* Automatically determining the user's current resolution and providing that value to the `resolution` variable.
* Add support for KDE and "generic" VNC sessions