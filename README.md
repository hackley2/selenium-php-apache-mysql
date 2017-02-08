# selenium-php-apache-mysql
Docker image containing everything needed to run BDD and TDD tests using Selenium, PHP, Apache, MySQL, and Redis on a CI server such as Bitbucket Pipelines.

# Supported Tags:
latest, php5.6

# How to Use:
All services are stopped by default, so you'll need to start and configure the services as needed. Here are the basics:

## Apache
Enable rewrite module:
```bash
a2enmod rewrite
```

Start Apache:
```bash
apache2ctl start
```

**Tip:** Apache will need to be further configured as needed. If you're not sure where to start, setting up a `/etc/apache2/sites-available/vhosts.conf` file would be a good first step.

## MySQL
Start MySQL:
```bash
/etc/init.d/mysql start
```
**Tip:** By default, MySQL server allows localhost `root` connections without specifying a password.

## Redis
Start Redis:
```bash
nohup redis-server &
```

## Selenium
Start Selenium:
```bash
export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"
xvfb-run --server-args="$DISPLAY -screen 0 $GEOMETRY -ac +extension RANDR" nohup java -jar /opt/selenium/selenium-server-standalone.jar &
```

Example Behat Configuration YAML File (adapt to your needs as necessary... this example is based off of a Laravel framework + Mink w/ Goutte driver environment):
```yaml
default:
    extensions:
        Laracasts\Behat\ServiceContainer\BehatExtension: ~

        Behat\MinkExtension:
            laravel: ~
            goutte: ~
            selenium2:
                wd_host: 127.0.0.1:4444/wd/hub
                capabilities:
                    browser: chrome
                    version: ANY
            default_session: goutte
            javascript_session: selenium2
            browser_name: chrome
            base_url: http://your-local-app-url.com # assumes proper setup of your apache /etc/apache2/sites-available/vhosts.conf and /etc/hosts file
```
