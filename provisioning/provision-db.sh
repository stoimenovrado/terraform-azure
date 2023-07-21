echo "* Update repository ..."
sudo apt-get update -y
sleep 10
sudo apt-get update -y

echo "* Reconfigure UFW ..."
sudo ufw allow 22
sudo ufw allow 3306
sudo ufw default allow outgoing

echo "* Install needed mods and extensions ..."
sudo apt-get install vim git mariadb-server -y

echo "* Reconfigure mariadb ..."
sudo sed -i.bak s/127.0.0.1/0.0.0.0/g /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
sudo systemctl enable mariadb

echo "* Copy the app and configure it ..."
sudo mkdir bgapp
cd bgapp
sudo git clone https://github.com/stoimenovrado/devopshomework.git
sudo mysql -u root < devopshomework/db/db_setup.sql

echo "* Update resolv.conf file to use the private DNS zone ..."
sudo sh -c 'echo "nameserver 168.63.129.16" >> /etc/resolv.conf'
