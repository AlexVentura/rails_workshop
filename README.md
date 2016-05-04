# How to use GitHub
## Another title


1. Item 1
2. Item 2
3. Item 3
   * Item 3a
   * Item 3b

http://lenguajemx.com - automatic!
[LenguajeMX](http://lenguajemx.com)


--

ssh azureuser@23.102.160.137

# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew -v
brew doctor

# Install ssh-copy-id in Mac
brew install ssh-copy-id

# Show our public ssh key
cat ~/.ssh/id_rsa.pub

# Copy our public key to the VPS
ssh-copy-id azureuser@23.102.160.137
	# Enter your VPS user password
	# Enter your SSH's KEY password

# Create a new user to deploy our RoR App
sudo adduser deploy
sudo adduser deploy sudo
su deploy

# Copy our public key to the VPS's "deploy" user
ssh-copy-id deploy@23.102.160.137
	# Enter your VPS's "deploy" user's password

# -------------------- Installing Ruby ---------------------------

# The first step is to install some dependencies for Ruby.
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

# The installation for rvm is pretty simple:
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.3.0
rvm use 2.3.0 --default
ruby -v

# Tell Rubygems not to install the documentation for each package locally
echo "gem: --no-rdoc --no-ri" > ~/.gemrc

# The last step is to install Bundler
gem install bundler

# -------------------- Installing Nginx ---------------------------

# Phusion is the company that develops Passenger and they recently put out an official Ubuntu
# package that ships with Nginx and Passenger pre-installed.
# We'll be using that to setup our production server because it's very easy to setup.
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add Passenger APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger & Nginx
sudo apt-get install -y nginx-extras passenger

# Next, we need to update the Nginx configuration to point Passenger to the version of Ruby
# that we're using. You'll want to open up /etc/nginx/nginx.conf in your favorite editor.
# I like to use vim, so I'd run this command:
sudo vim /etc/nginx/nginx.conf

# You could also use nano if you don't like vim
# sudo nano /etc/nginx/nginx.conf

# Change user to deploy
user deploy;

### Find the following lines, and uncomment them:

##
# Phusion Passenger
##
# Uncomment it if you installed ruby-passenger or ruby-passenger-enterprise
##

passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;

# passenger_ruby /home/deploy/.rbenv/shims/ruby; # If you use rbenv
passenger_ruby /home/deploy/.rvm/wrappers/ruby-2.3.0/ruby; # If use use rvm, be sure to change the version number
# passenger_ruby /usr/bin/ruby; # If you use ruby from source

# Once you've changed passenger_ruby to use the right version Ruby, you can run the next command
# to restart Nginx with the new Passenger configuration.
sudo service nginx restart

# You can get logs at:
sudo tail /var/log/nginx/error.log

# -------------------- Install MySQL ---------------------------

# First, update apt-get:
sudo apt-get update

# Then install MySQL and its development libraries:
sudo apt-get install mysql-server mysql-client libmysqlclient-dev

# During the installation, your server will ask you to select and confirm a password for
# the MySQL "root" user.

# When the installation is complete, we need to run some additional commands to get our MySQL
# environment set up securely. First, we need to tell MySQL to create its database directory
# structure where it will store its information. You can do this by typing:
sudo mysql_install_db

# Afterwards, we want to run a simple security script that will remove some dangerous
# defaults and lock down access to our database system a little bit. Start the
# interactive script by running:
# You will be asked to enter the password you set for the MySQL root account.
sudo mysql_secure_installation

# Next, it will ask you if you want to change that password.
# If you are happy with your current password, type n at the prompt.

# For the rest of the questions, you should simply hit the "ENTER" key through each prompt
# to accept the default values. This will remove some sample users and databases, disable
# remote root logins, and load these new rules so that MySQL immediately respects the
# changes we have made.

# MySQL is now installed, but we still need to install the MySQL gem.

# -------------------- Install MySQL Gem ---------------------------

# Before your Rails application can connect to a MySQL server, you need to install the
# MySQL adapter. The mysql2 gem provides this functionality.

# As the Rails user, install the mysql2 gem, like this:
# Now your Rails applications can use MySQL databases.
gem install mysql2

# -------------------- Crear un nuevo usuario y otorgarle permisos en MySQL ---------------------------

# ¿Cómo crear un nuevo usuario?
# Vamos empezando por crear un usuario nuevo desde la consola de MySQL:
CREATE USER 'nombre_usuario'@'localhost' IDENTIFIED BY 'tu_contrasena';

# Lamentablemente, a este punto el nuevo usuario no tiene permisos para hacer algo con las
# bases de datos. Por consecuencia si el usuario intenta identificarse (con la contraseña
# establecida), no será capaz de acceder a la consola de MySQL.

# Por ello, lo primero que debemos hacer es porporcionarle el acceso requerido al
# usuario con la información que requiere.
GRANT ALL PRIVILEGES ON * . * TO 'nombre_usuario'@'localhost';

# Una vez que has finalizado con los permisos que deseas configurar para tus nuevos
# usuarios, hay que asegurarse siempre de refrescar todos los privilegios.
FLUSH PRIVILEGES;

# También puedes usar el comando DROP para borrar usuarios:
DROP USER ‘usuario_prueba’@‘localhost’;

# Probamos el nuevo usaurio con éste comando:
mysql -u [nombre de usuario] -p

# -------------------- Capistrano Setup ---------------------------

# For Capistrano, make sure you do these steps on your development machine inside your
# Rails app. The fancy new verison of Capistrano 3.0 just shipped and we're going to
# be using it to deploy this application.

# The first step is to add Capistrano to your Gemfile:
group :development do
	gem 'capistrano', '~> 3.1.0'
	gem 'capistrano-rails', '~> 1.1.1'
	gem 'capistrano-bundler', '~> 1.1.2'

	# Add this if you're using rbenv
	# gem 'capistrano-rbenv', github: "capistrano/rbenv"

	# Add this if you're using rvm
	gem 'capistrano-rvm', github: "capistrano/rvm"
end

# Run
bundle install

# Once these are added, run:
bundle --binstubs

# and then: to generate your capistrano configuration.
cap install STAGES=production

# Next we need to make some additions to our ""Capfile"" to include bundler, rails, and
# benv/rvm (if you're using them). Edit your ""Capfile"" and add these lines:
require 'capistrano/bundler'
require 'capistrano/rails'

# If you are using rbenv add these lines:
# require 'capistrano/rbenv'
# set :rbenv_type, :user # or :system, depends on your rbenv setup
# set :rbenv_ruby, '2.0.0-p451'

# If you are using rvm add these lines:
require 'capistrano/rvm'
set :rvm_type, :user
set :rvm_ruby_version, '2.3.0'

# After we've got Capistrano installed, we can configure the ""config/deploy.rb"" to setup
# our general configuration for our app. Edit that file and make it like the following
# replacing "myapp" with the name of your application and git repository:
set :application, 'myapp'
set :repo_url, 'git@github.com:excid3/myapp.git'

set :deploy_to, '/home/deploy/myapp'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do
	desc 'Restart application'
	task :restart do
		on roles(:app), in: :sequence, wait: 5 do
			execute :touch, release_path.join('tmp/restart.txt')
		end
	end

	after :publishing, 'deploy:restart'
	after :finishing, 'deploy:cleanup'
end

# Now we need to open up our ""config/deploy/production.rb"" file to set the server IP
# address that we want to deploy to:
set :stage, :production

# Replace 127.0.0.1 with your server's IP address!
server '127.0.0.1', user: 'deploy', roles: %w{web app}

# If you have any trouble with Capistrano or the extensions for it, check out
# Capistrano's Github page.

# -------------------- Final Steps ---------------------------

# Thankfully there aren't a whole lot of things to do left!

# Adding The Nginx Host
# In order to get Nginx to respond with the Rails app, we need to modify it's sites-enabled.

# Open up ""/etc/nginx/sites-enabled/default"" in your text editor and we will replace the
# file's contents with the following:
server {
	listen 80 default_server;
	listen [::]:80 default_server ipv6only=on;

	server_name mydomain.com;
	passenger_enabled on;
	rails_env    production;
	root         /home/deploy/myapp/current/public;

	# redirect server error pages to the static page /50x.html
	error_page   500 502 503 504  /50x.html;
	location = /50x.html {
		root   html;
	}
}

# This is our Nginx configuration for a server listening on port 80. You need to change the
# server_name values to match the domain you want to use and in root replace "myapp" with
# the name of your application.

# Install NodeJS for the assets to be compiled
sudo apt-get install nodejs
