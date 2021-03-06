# vagrant-ubuntu-trusty-magento2
Vagrant Box set up with all dependencies and magento2.

## Prerequisites 
minimum requirements you will need a dual core computer with 4GB ram running very efficiently, this is recommended to be run on a computer with 4 or more cores and at least 8GB of ram. 

This is a vagrant project and so requires __vagrant__, this particular vagrant project is set up to use __VirtualBox__ as the VM so that is also a requirement. this was set up on windows 10 but should work on other Operating systems with the correct set up (libvirt and KVM does not work with this vagrant box) it's not a requirement but the installation of docker / docker-tools is advised for a great development environment. you will also obviously need __git__, it is also generally a requirement of development to have installed __composer__, __nodejs__ ect on the host machine.

You will also need an SSH client like __PuTTy__

## Setup 
open up a cmd window and clone this git repository into a sensible directory :

`git clone https://github.com/domnoble/vagrant-ubuntu-trusty-magento2.git`

change to the project directory and then add the magento2 directory(location to place magento2 files) 

`cd vagrant-ubuntu-trusty-magento2`

`mkdir magento2`

It is then advised to download the stable magento version from the magento website and place it in a subdirectory(`~/magento2/`) rather than trying to clone the unstable development branch from github, after setting up vagrant with magento2 from their website, i attempted to use the development branch but i had problems trying to get composer, php and node to set up and install the git magento2 automagically. because of this i decided for this purpose it would be simpler to use the stable version with sample data from the magento website and leave it as a manual installation. 

[Magento2 CE Download](https://www.magentocommerce.com/download "Open Source Ecommerce MCE")

## Configuration
By default this project is set up to use 2GB of ram and 2 CPU cores, if you are running on any minimum requirements then you will need to go into the Vagrant file and alter the `config.vm.provider` accordingly, i.e set the cpus to 1 : 

```
config.vm.provider "virtualbox" do |vb|
      # vb.gui = true
      vb.memory = 2048
      vb.cpus = 1
  end
```

## Launching
Navigate into the root project directory in a commandline, then run vagrant up command
`vagrant up`

## Magento2 Installation
Assuming you kept the default configuration if we now visit 127.0.0.1 or localhost, we should be greeted by the magento installation, click get started and then go through the pre checks and configuration filling out the details shown below, set your prefered currency, time and language settings and create an admin account, then proceed with the installation.

```
Database Name : magento
Database User : mageuser
Database Pass : magepass
```

## Post Installation 
you will most likely find that the images and fonts in magento dont all display correctly, to fix this you can use an ssh client like putty to connect to the VM and run a couple of commands. to get the login details run `vagrant ssh` in a command line at the project root folder, that should output something similar to this on windows (assuming you haven't installed ssh binaries into your path) : 
```
Host: 127.0.0.1
Port: 2222
Username: vagrant
Private key: C:/Users/User/dev/vagrant-ubuntu-trusty-magento2/.vagrant/machines/default/virtualbox/private_key
```
Copy the Private Key path from the command line to the clipboard `Ctrl + C`. In the PuTTy config navigate to __Connection > SSH > Auth__ and paste `Ctrl + V` the path to the input field at the bottom labeled with __Private key file for authentication__, navigate back to __Session__ and set the hostname to __localhost__ and the port to __2222__. then click open and accept the RSA keys.

The SSH login information on all Vagrant installs is normally:
```
Username : vagrant
Password : vagrant
```
Once you are in you need to initialize the static files like js, css and images. I normally change the ownership of the files to www-data but i dont think this is essential for getting it to work properly.

`sudo chown -R www-data:www-data /vagrant/magento2`

`cd /vagrant/magento2`

`php bin/magento setup:static-content:deploy`

`sudo cp /vagrant/di.xml /vagrant/magento2/app/etc/di.xml`

## Bugs & Frequent issues
While testing i came accross several issues relating to VirtualBox....

If the host only adapters are filled in virtualbox there will be a failure, this can be solved by going into the VirtualBox GUI and navigating to __File > Preferneces > Network > Host-only Networks__ and deleting some if not all of the host-only adapters. this can get filled fairly quickly if say you use something like kitematic with docker-tools. 

Vagrant also requires the latest VirtualBox so if you are running an older version there may be some issues creating a VM.

Sometimes Windows 10 would freeze during VM creation.

This box is set up to use port 80 on the host machine, if you allready have a webserver on localhost then this can be changed in the VagrantFile config section `config.vm.network` before launch. 





