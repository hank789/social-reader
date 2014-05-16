## 创建帐号

假设你已经用 root 帐号通过 SSH 登陆服务器。

出于安全考虑，不要使用 root 帐号运行 web 应用。这里新建一个专门用于部署的用户，例如 poqbod 或者其它你喜欢的名字。运行以下命令创建用户：

```
# useradd -m -s /bin/bash poqbod
```

将用户加入 sudo 群组，以便使用 sudo 命令：

```
# adduser poqbod sudo
```

为 deploy 用户设置密码：

```
# passwd poqbod
```

退出当前 SSH 链接，用 poqbod 帐号重新登陆。

## 安装 RVM 和 Ruby

更新 apt，并安装 curl：

```
$ sudo apt-get update
$ sudo apt-get install curl
```

然后安装 RVM：

```
$ \curl -sSL https://get.rvm.io | bash
```

RVM 安装完毕后，重新登陆 SSH，让 RVM 配置生效。然后安装 Ruby 2.1.1：

```
$ rvm use --install --default 2.1.1
```

Ruby 安装过程会请求 `apt-get update` 的权限，并自动安装系统依赖。安装完毕后，确认目前的 Ruby 版本：

```
$ ruby -v
```

应该看到 `ruby 2.1.1` 字样。


# 4. Database

We recommend using a PostgreSQL database. For MySQL check [MySQL setup guide](database_mysql.md).
NOTE: because we need to make use of extensions you need at least pgsql 9.1.

    # Install the database packages
    sudo apt-get install -y postgresql-9.1 postgresql-client libpq-dev

    # Login to PostgreSQL
    sudo -u postgres psql -d template1

    # Create a user for GitLab.
    template1=# CREATE USER git CREATEDB;

    # Create the GitLab production database & grant all privileges on database
    template1=# CREATE DATABASE gitlabhq_production OWNER git;

    # Quit the database session
    template1=# \q

    # Try connecting to the new database with the new user
    sudo -u git -H psql -d gitlabhq_production


# 5. GitLab

    # We'll install GitLab into home directory of the user "git"
    cd /var/www

## Clone the Source

    # Clone poqbod repository
    sudo git clone git@github.com:pafa/poqbod.git

    # Go to poqbod dir
    cd /var/www/poqbod

## Configure it

    cd /var/www/poqbod

    # Copy the example GitLab config
    sudo cp config/gitlab.yml.example config/gitlab.yml

    # Make sure to change "localhost" to the fully-qualified domain name of your
    # host serving GitLab where necessary
    #
    # If you installed Git from source, change the git bin_path to /usr/local/bin/git
    sudo vi config/gitlab.yml

    # Make sure poqbod can write to the log/ and tmp/ directories
    sudo chown -R poqbod log/
    sudo chown -R poqbod tmp/
    sudo chmod -R u+rwX log/
    sudo chmod -R u+rwX tmp/

    # Make sure poqbod can write to the tmp/pids/ and tmp/sockets/ directories
    sudo chmod -R u+rwX tmp/pids/
    sudo chmod -R u+rwX tmp/sockets/

    # Make sure poqbod can write to the public/uploads/ directory
    sudo chmod -R u+rwX  public/uploads

    # Copy the example Unicorn config
    sudo cp config/unicorn.rb.example config/unicorn.rb

    # Enable cluster mode if you expect to have a high load instance
    # Ex. change amount of workers to 3 for 2GB RAM server
    sudo vi config/unicorn.rb

    # Copy the example Rack attack config
    sudo -u poqbod -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

**Important Note:**
Make sure to edit both `gitlab.yml` and `unicorn.rb` to match your setup.

## Configure poqbod DB settings

    # PostgreSQL only:
    sudo -u poqbod cp config/database.yml.postgresql config/database.yml

    # MySQL only:
    sudo -u poqbod cp config/database.yml.mysql config/database.yml

    # MySQL and remote PostgreSQL only:
    # Update username/password in config/database.yml.
    # You only need to adapt the production settings (first part).
    # If you followed the database guide then please do as follows:
    # Change 'secure password' with the value you have given to $password
    # You can keep the double quotes around the password
    sudo -u poqbod -H editor config/database.yml

    # PostgreSQL and MySQL:
    # Make config/database.yml readable to git only
    sudo -u poqbod -H chmod o-rwx config/database.yml

## Install Gems

   bundle install


## Initialize Database and Activate Advanced Features

    bundle exec rake db:migrate RAILS_ENV=production

    bundle exec rake db:seed_fu RAILS_ENV=production

## Install Init Script

Download the init script (will be /etc/init.d/gitlab):

    sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab

And if you are installing with a non-default folder or user copy and edit the defaults file:

    sudo cp lib/support/init.d/gitlab.default.example /etc/default/gitlab

If you installed gitlab in another directory or as a user other than the default you should change these settings in /etc/default/gitlab. Do not edit /etc/init.d/gitlab as it will be changed on upgrade.

Make GitLab start on boot:

    sudo update-rc.d gitlab defaults 21

## Set up logrotate

    sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab


## Compile assets

    sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production

## Start Your GitLab Instance

    sudo service gitlab start
    # or
    sudo /etc/init.d/gitlab restart


# 6. Nginx

**Note:**
Nginx is the officially supported web server for GitLab. If you cannot or do not want to use Nginx as your web server, have a look at the
[GitLab recipes](https://gitlab.com/gitlab-org/gitlab-recipes/).

## Installation
    sudo apt-get install -y nginx

## Site Configuration

Download an example site config:

    sudo cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
    sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab

Make sure to edit the config file to match your setup:

    # Change YOUR_SERVER_FQDN to the fully-qualified
    # domain name of your host serving GitLab.
    sudo editor /etc/nginx/sites-available/gitlab

## Restart

    sudo service nginx restart


# Done!