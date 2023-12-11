#!/usr/bin/sh

sudo apt update && sudo apt full-upgrade -with-new-pkgs -y && sudo apt autoremove && sudo apt autoclean

# Automatic security updates / Автоматические обновления безопасности
sudo apt install unattended-upgrades
# These lines configure unattended-upgrades so that it runs automatically. Here's what they do:
# - APT::Periodic::Update-Package-Lists "1" means that the list of packages will be automatically updated every day. / означает, что список пакетов будет автоматически обновляться каждый день.
# - APT::Periodic::Unattended-Upgrade "1"   means that the system will be updated to the latest version of the packages without the user having to intervene. / означает, что система будет обновлена до последней версии пакетов без вмешательства пользователя.
# - APT::Periodic::AutocleanInterval "7"    means that the auto-clean operation, which gets rid of old and unnecessary package files, will run once a week. / означает, что операция автоматической очистки, позволяющая избавиться от старых и ненужных файлов пакета, будет выполняться раз в неделю.
sudo echo 'APT::Periodic::Update-Package-Lists "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
sudo echo 'APT::Periodic::Unattended-Upgrade "1";'   >> /etc/apt/apt.conf.d/20auto-upgrades
sudo echo 'APT::Periodic::AutocleanInterval "7";'    >> /etc/apt/apt.conf.d/20auto-upgrades

# Отредактировать /etc/apt/apt.conf.d/50unattended-upgrades так, чтобы система автоматически перезагружалась, когда этого требуют обновления ядра:
sudo echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
# ToDo: https://www.cyberciti.biz/faq/ubuntu-enable-setup-automatic-unattended-security-updates/

# sudo adduser fastapi-user # replace fastapi-user with your preferred name
# sudo gpasswd -a fastapi-user sudo # add to sudoers
# su - fastapi-user # login as fastapi-user 

sudo apt-get install software-properties-common # https://itsfoss.com/add-apt-repository-command-not-found/
sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt update
sudo apt install python3.11 python3.11-venv -y

sudo apt install supervisor -y
sudo systemctl enable supervisor
sudo systemctl start supervisor

# sudo apt install nginx -y
# sudo apt install mc -y
sudo apt install -y yarn synaptic finger htop curl wget lynx unzip

cd ~
git clone https://github.com/dylanjcastillo/fastapi-nginx-gunicorn-application
cd fastapi-nginx-gunicorn-application

python3 -m venv env

. env/bin/activate

pip install -r requirements.txt
pip install -r requirements-dev.txt

chmod u+x gunicorn_start
mkdir run
mkdir logs

sudo ln -s fastapi-app.conf /etc/supervisor/conf.d/

sudo supervisorctl reread
sudo supervisorctl update
# checking:
# sudo supervisorctl status fastapi-app
# or
# curl --unix-socket /home/fastapi-user/fastapi-nginx-gunicorn/run/gunicorn.sock localhost

# if you make changes to the code, you can restart the service to apply to changes by running this command:
# sudo supervisorctl restart fastapi-app

# не забудте изменить значение server_name в файле
cp fastapi-app /etc/nginx/sites-available/fastapi-app
sudo ln -s /etc/nginx/sites-available/fastapi-app /etc/nginx/sites-enabled/
# sudo nginx -t # checking
sudo systemctl restart nginx

sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo ln -s /snap/bin/certbot /usr/bin/certbot