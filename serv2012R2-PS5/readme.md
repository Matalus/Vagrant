# IIS Bootstrapped Sandbox
Created by Matt Hamende

This is my full bootstrapped Server 2012R2 VM that I use for sandbox testing, 
This [Vagrantfile](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/Vagrantfile) and included [scripts](https://github.com/Matalus/Vagrant/tree/master/serv2012R2-PS5/shell) will:
* Setup [WinRM](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/winrm_firewall.ps1) listener and firewall rules
* Port Forward Guest 80,443 to local ports 8888, 8443
* Install [Chocolatey](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/InstallChocolatey.ps1)
* [Install](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/InstallChocoPackages.bat) / Update : PowerShell Core, PowerShell 5.1, NodeJS, VS-Code, Notepad++, Chrome, GIT, PuTTy, AWS PowerShell Module
* Setup a Test user [WMIUSER](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/wmiuser.bat) with Read-only WinRM permissions to [WMI]https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/Set-WmiNamespaceSecurity-Root.ps1 / [DCOM](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/Set-DCOMPermissions.ps1) (related to prior permissions project)
* Install and Configure [IIS](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/Install-IIS.ps1)
* [Deploy](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/Deploy-Test-Sites.ps1) 5 IIS Test Sites with Self-Signed Certs
* Deploy [hosts](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/shell/hosts) File locally to point all test site references to loopback adapter


### Prerequisites

Built using virtualbox 6.0, vagrant 2.2.4, PowerShell 5.1

### Installing

* Install Vagrant
* Install Virtual Box
* From directory of Vagrantfile run **vagrant up**
* (optional) Add the following hostfile [Hosts](https://github.com/Matalus/Vagrant/blob/master/serv2012R2-PS5/Hosts) (c:\windows\system32\drivers\etc\hosts) on your local machine's hosts file to get sites to resolve locally, remember to run **ipconfig /flushdns** any time you modify Hosts

## Built With

* [Vagrant](https://www.vagrantup.com/) - VM Orchestration
* [VirtualBox](https://www.virtualbox.org/) - Virtualization Provider
* [Chocolatey](https://chocolatey.org/) - Windows Package Management

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Caveats

If you recieve an error like **Failed to attach the network LUN (VERR_INTNET_FLT_IF_NOT_FOUND).**
* Sometimes windows updates will break the Host-Only network adapter for Virtualbox, where it's necessary to disable the NDIS6 Driver, then disable and re-enable the network interface [link](https://www.virtualbox.org/ticket/14832)

## Acknowledgments

* Thank you to anyone that either helped me or from who I begged, borrowed or stole code to build this project