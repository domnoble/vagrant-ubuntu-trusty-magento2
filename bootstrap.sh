#!/usr/bin/env bash
#
# MySQL server 5.6 and MySQL cli interface install, you can set the root database password here, the default password is "rootpass".
# todo : add options for more database versions like mariaDB, SQLite ect and add variable for password from vagrant if possible
#
echo "Starting MySQL Install"
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password rootpass'
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password rootpass'
sudo apt-get -y update
apt-get -y install mysql-server-5.6 mysql-client-5.6
#
# Apache2 installation, this could also be changed to nginx
# todo : add switch between nginx and apache
#
echo "Starting Apache2 Install"
apt-get -y install apache2
echo "Apache should be version >= 2.4, the current version is :"
apache2 -v
#
# Installation of PHPFPM with PHP7.0, PHP5.6 and all the magento dependencies using the recommended ondrej/php PPA.
#
echo "Adding ondrej PPA(ppa:ondrej/php) for PHP7 binaries"
sudo add-apt-repository ppa:ondrej/php
sudo apt-get -y update
sudo apt-get install -y php7.0 libapache2-mod-php7.0 php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-intl php7.0-xsl php7.0-mbstring php7.0-zip php7.0-bcmath
#
# enable apache rewrites
#
echo "Setting up Apache Rewrites"
a2enmod rewrite
service apache2 restart
#
# Installation of curl, git, ruby, node & npm
#
#echo "Installing Curl, Git, NodeJS, npm, grunt & bower"
#sudo apt-get -y install php5-cli php5-curl
#sudo apt-get -y install curl git nodejs npm ruby
#npm install -g grunt bower > /dev/null 2>&1
#
# Installation of composer
#
#sudo wget https://getcomposer.org/installer
#mv composer.phar /usr/local/bin/composer
#
# Checks if database is already setup if /var/log/databasesetup doesn't exist it will set up a database and database user
# todo : add variable for db_name, username and password carry variable from initial root password setup
#
if [ ! -f /var/log/databasesetup ];
then
    echo "Creating DB and DB user"
    echo "CREATE USER 'mageuser'@'localhost' IDENTIFIED BY 'magepass'" | mysql -uroot -prootpass
    echo "CREATE DATABASE magento" | mysql -uroot -prootpass
    echo "GRANT ALL ON magento.* TO 'mageuser'@'localhost'" | mysql -uroot -prootpass
    echo "flush privileges" | mysql -uroot -prootpass
    touch /var/log/databasesetup
fi
#
# Checks to see if magento2 and php directory symlink exists if not it starts the installation of magento2
#
if [ ! -h /var/www/php ];
then
#
# Checks to see if magento2 directory exists if it doesn't then it starts the cloning of magento2 and sample data from github, it is advised to instead download & extract magento2 and sample data
# into <current_directory>/magento2/ using the download the stable from the magento website instead of github development branch downloaded by this script.
#
#    if [ ! -d /vagrant/magento2/ ];
#    then
#        echo "Cloning magento2 from git as magento2 doesn't exist"
#        echo "Warning : this will clone magento development branch from git, this is not the advised method for setting up magento2, it is advised to download the latest magento2 with sample data from the magento release website"
#        git clone https://github.com/magento/magento2.git /vagrant/magento2
#        git clone --no-checkout https://github.com/magento/magento2-sample-data.git /vagrant/magento2/sample_data.tmp
#        sudo rm -Rf /vagrant/magento2/sample_data.tmp/.git
#        sudo -R /vagrant/magento2/sample_data.tmp/ /vagrant/magento2/
#        sudo -Rf /vagrant/magento2/sample_data.tmp/
#        cp package.json.sample package.json
#    fi
#
# removes old default apache config and web directory then copies virtualhost config from vagrant directory and sets up a symlink from /var/www/php to /vagrant/magento2
#
    echo "linking Magento to public directory and configuring virtualhost"
    sudo rm -rf /var/www/html
    sudo a2dissite 000-default
    service apache2 restart
    mv /etc/apache2/sites-available/000-default.conf /vagrant/000-default.conf.old
    sudo cp /vagrant/vhost.conf /etc/apache2/sites-available/000-default.conf
    sudo ln -s /vagrant/magento2 /var/www/php
    sudo a2ensite 000-default
    service apache2 restart
#
#
#
#cd /vagrant/magento2
#
#sudo -u vagrant -H sh -c "composer install"
#sudo -u vagrant -H sh -c "npm install"
#sudo -u vagrant -H sh -c "grunt"
#
# fixes a problem in magento that stops images showing correctly due to symlinks in pub/static.
#
sudo cp /vagrant/di.xml /vagrant/magento2/app/etc/di.xml
#
# installs via the magento cli
# todo : need to add piping for variables for all the magento install options so they can be changed using vagrant and carry over other variables for DB.
#
#
# php bin/magento setup:install --admin-firstname=magento --admin-lastname=admin --admin-email=example.com --admin-user=admin --admin-password=pwd1234 --base-url=http://127.0.0.1/ --backend-frontname=admin --db-host=localhost --db-name=magento --db-user=mageuser --db-password=magepass --language=en_GB --currency=GBP --timezone=Europe/London --use-rewrites=1 --use-secure=0 --base-url-secure=0 use-secure-admin=0 --admin-use-security-key=1 --session-save=db
# php bin/magento setup:static-content:deploy
#
# transfers ownership of files over to apache www-data user
#
# sudo chown -R www-data:www-data /vagrant/magento2
fi
#
# Aesthetics..........
#
printf "
 ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  ..
....................................................................................................................................................................................
 ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  ..
 ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  ..

 ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  ..
                                                         ....                                                                               ...........
                                                       .NDDI.                                                                               ...........
....................................................... DDDI................................................... ...............................?I7III7,.............................
                                                        DDDI.                                                 NND .                         .?III7I7..II...
....................................................... DDDI................................................. DDD ..........................~7I7.+?=.:III...........................
                                     .   ..      .      DDDI.   ..       ......      .....       ..           DDD..   .   .....       . .   I?+.7IIII.$I7..
..................................... DNN=.......DNN  . DDD?NDNDDNO.  ... ,NND...... 7NNO..  .78NDNDDDO.. ... DDDDDNNND+...NNN ......+NND ..7:.:7IIII,?I7...........................
.  ..  .. ..  ..  .  ..  .. ..  ..  . NDD=... .. DDD .. DDDDNDDDDDNDN.... ,DDD... .. 7DDO....DDDNDDNDDDDN.... DDDNDDDDN+  .NDD.  ..  +DDD   +III.7II..III...  ..  .  ..  .. ..  ..
.  ..  .. ..  ..  .  ..  .. ..  ..  . NDD=... .. DDD .. DDDI. .....NDN:.. ,DDD... .. 7DDO....DDN..  ..,DNN .. DDD..   ..  .NDD.  ..  +DDD   .II7I+,~.,II,...  ..  .  ..  .. ..  ..
..................................... NDD=...... DDD .. DDD?........NDD.. ,DDD...... 7DDO....DDD.......DDDI.. NDD .........NDD.......+DDD ....:II7I7I7+.............................
                                      NDD=.      DDD .  DDDI.       =NDN  ,DDD.      7DDO. ..DDD.     .ZDDZ. .DDD .       .NDD.      +DDD       ..,....
..................................... NDD=...... DDD .. DDDI.........NDD. ,DDD...... 7DDO....DDD.......ZDDZ...DDD .........NDD.......+DDD ..........................................
 ..  ..  .  ..  .. ..  ..  .  ..  ..  NDD=.  .   DDD .  DDDI.  .  ...NDD. ,DDD.  .   7DDO. ..DDD.  .  .ZDDZ. .DDD .  .  ...DDD...  ..+NDD ..  .. ..  ..  .  ..  .. ..  ..  .  ..  ..
                                      DDD+.      DDD .  DDDI.      .DDNZ..,DDN.      7DDO. ..DDD.     .ZDDZ.  DDD .       .DDD.      +DDD
                                     .+NND.......DDD .  DDDI.......8DDD. . DNN.......7DDO. ..DDD.     .ZDDZ.  NDD.....     DDD...... +DDD
                                       DDDD:.....NDD .  DDD7.....ZDDN8..   ,DND~.....~DDO. ..DDD.     .ZDDZ.  ,DND...      =DNDZ.....IDDD
                                       .+DDNDDDDNNDD .  DDDNDDNNDDDD....   ..DDNDNDDDNDDO. ..DDD.     .ZDDZ. ...DNNDDDND   ..DNNDNNDNNNDD
                                       .   .:~:.        .. .,:~,..  ..          .~~,... .   .  .      .        .. .,,       ....,~::. .. .
                                              ....                            .....                               ....



                                                                                      I7?.
                                                                                      MM8.
                                                                                      MM8
                                                                                 ~MMMMMMMMMMM
                        .....                                                    :MMMMMMMMMMM
                        ..~..                                                    .....MM8.. .
                 ... ..~=====~......                                                  MM8                                                          ..  ..............
                 ...,===========,...                                                  MM8.                                                         .......:+???+:.. .
          ...... .========.~=======. ......                                                                                                        ..:?IIIIIIIIIIIII,....
          .....:=======:.....:======~:.....                                                                                                        ?IIIIIIIIIIIIIIIII7...
          ...~=======,.... ....,=======~...     ..                                                                                                 ,IIIIIIIIIIIIIIIIII=..
          .=======~......    .....:=======.      .MMM:.         MMMN                                                      ..,.                     .IIIIIIIIIIIIIIIIIII..
          .II?==.... . ..   .. . .. .~=?II.     .?MMMM         +MMMM                                                      NMD.                     .III?,.....=IIIIIIII..
          .IIII.. ...,==.   .==,......IIII       NMMNM+.      .MMMMM..                                                    NMD.              ..,.   .I,.   .....7IIIIIII..
 ..  ..  ..IIII....~====.  ..====~....IIII   .   MMOIMM..  .. ~MM?MM. ....IO8O?  .  ..:Z8Z.  .?..  I8OI. ...~~...~OO~.  ~=NMD=~:    I88I  . :~., ......  .....IIIIIIII~..  .  ..  ..
          .IIII.. .II?==.   .==?II....IIII       MMI.MMM.    .MM.,MM.   MMMMMMMMM...~MMMMMMMMMM,.MMMMMMMM, .8MDMMMMMMMD DMMMMMMN .MMNMMMMM:.O.I    .  ......,IIIIIIII?...
          .IIII....IIIII,   ,IIIII ...IIII      .MM= .MM.    MMO. MM,    . .  :MM .=MM    .MM,..MM8.   DMM..8MMM....~MM...NMD. .,MM7....=MM.           ... IIIIIIII7: ...
 ..  ..  ..IIII....IIIII:  .,IIIII ...IIII   .  .MM...DMM  .ZMM.. MM? .. .. ,=ZMM .ZMM  ...MM?.7MM,....,MM,.8MM.....=MM ..NMD.  MMD..  ..MMM  .. ..  ....:IIIIIIIII.. ...  .  ..  ..
          .IIII....IIIII:   ,IIIII ...IIII    . .MM. ..MM7..MM+...MMD   7MMMMMMMM.. MMO.. NMM..MMMMMMMMMMM7.8MM    .=MM   NMD...MM? .   .ZMM .     .....?IIIIIIII+...
          .IIII....IIIII:   ,IIIII ...IIII    . .MM. ..,MM.OMM. . MMM. MMM.. ..MM.. .NMMMMM8...OMM..    ....8MM     =MM   NMD...MMZ..   .8MM       ...+IIIIIII7+.....
          .IIII....IIIII:   ,IIIII ...IIII    . ~MM...  MM8MM   . OMM.,MM..  ..MM.. :MM,..     ,MM?.    ....8MM     =MM   NMD.  ZMM..   .MM?       .:IIIIIIII?... .......
...........IIII....IIIII:...,IIIII ...IIII .....?MM .....MMM,.....?MM..MMM:,ZMMMM.. .MMMMMMM~...NMMM+:=NMM,.8MM.....=MM ..DMMD?I.DNMO,,8MMM...... .IIIIIIIIIIIIIIIIIIII=............
          .IIII....IIIII:   ,IIIII ...IIII.     OMM.     IMM.     ~MM   MMMMM+.MM .OMM . .DMMM~ . 8MMMMMN.  8MM     =MM.  .NMMMM.  MMMNMM      . ..IIIIIIIIIIIIIIIII?===.
          ..~II....IIIII:   ,IIIII ...II~..      ...        .     . .      ..  ....MN..   ..=MM .   ..   .         .         .  . .  ... .     . ..IIIIIIIIIIIIIII+=====.
          .........IIIII:   ,IIIII ........                                       .MMO    .:NMI .                                              . ..IIIIIIIIIIII+========.
 ..  ..  .  ..  ...IIIII~...,IIIII.. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .. ~MMMMMMND  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  ..   ......................  .  ..  ..
                 ...?IIII7:IIIII?...                                                 .   .                                                                    ........ ..
                     .,I7III7I,.
.........................=I=........................................................................................................................................................



 ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  .. ..  ..  .  ..  ..

"