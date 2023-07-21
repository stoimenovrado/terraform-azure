sudo ufw default allow outgoingecho "* Update repository ..."
sudo apt-get update -y
sleep 10
sudo apt-get update -y

echo "* Reconfigure UFW ..."
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

echo "* Install needed mods and extensions ..."
sudo apt-get install apache2 vim git php php-mysqlnd -y
sudo systemctl start apache2
sudo systemctl enable apache2

echo "* Copy the app and configure it ..."
sudo mkdir bgapp
cd bgapp
sudo git clone https://github.com/stoimenovrado/devopshomework.git
sudo cp devopshomework/web/* /var/www/html/
sudo mv /var/www/html/index.html /var/www/html/index.html-old

echo "* Edit the config file to look for the DB on the correct host ..."
file_path="/var/www/html/config.php"
old_word="db"
new_word="db.bgapp.test"
sudo sed -i "s/${old_word}/${new_word}/g" "$file_path"

echo "* Restart apache ..."
sudo systemctl restart apache2

echo "* Update resolv.conf file to use the private DNS zone ..."
sudo sh -c 'echo "nameserver 168.63.129.16" >> /etc/resolv.conf'
