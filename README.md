# vagrant-ubuntu-trusty-magento2
Vagrant Box set up with all dependencies and magento2. 
## Prerequisites 
This is a vagrant project and so requires vagrant, this particular vagrant project is set up to use VirtualBox as the VM so that is also a requirement. this was set up on windows 10 but should work on other OSes with the correct set up (libvirt and KVM does not work with this vagrant box) it's not a requirement but the installation of docker / docker-tools is advised for a great development environment.
## Installation 
download or clone this git repository
......
It is then advised to download the stable magento version from the magento website and place it in the magento 2 directory rather than trying to clone the development branch from github, after setting up vagrant with magento2 from their website, i attempted to use the development branch but i had problems trying to get composer, php and node to set up and install the git magento2 automagically. because of this i decided for this purpose it would be simpler to use the stable version with sample data from the magento website and leave it as a manual setup. 
