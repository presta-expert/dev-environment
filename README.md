# README

Bash script which with the help of docker will quickly create a ready dev environment for any version of PrestaShop.

Bundled with MariaDB, phpMyAdmin, MailHog and IonCube, along with a support for your own entries in php.ini.

## Usage

Just clone the repository

```bash
git clone https://github.com/presta-expert/dev-environment && cd dev-environment
```

Then just run bundled bash script [./bin/dev.sh](./bin/dev.sh) specifying the version of PrestaShop which you want to use
```bash
bin/dev.sh [up/down/start/stop/pause/build] prestashop_version

bin/dev.sh up 1.7.8.8
```
_NOTE: You may be asked for the sudo password to set permissions, please provide it or run the script with sudo and **NEVER** use it in production._

After a few moments your PrestaShop is installed and running at [http://localhost:8080](http://localhost:8080) _(BO: [http://localhost:8080/admin-dev](http://localhost:8080/admin-dev))_, your dev environment also includes:
- **[phpMyAdmin](https://github.com/phpmyadmin/phpmyadmin)** _(for database management)_ which is accessible from [http://localhost:3309](http://localhost:3309)
- **[MailHog](https://github.com/mailhog/MailHog)** and **[mhsendmail](https://github.com/mailhog/mhsendmail)** _(for local e-mail testing based on SMTP)_ which is accessible from [http://localhost:8025](http://localhost:8025)
- **[IonCube Loader](https://www.ioncube.com/loaders.php)** _(for loading secured php files, it is pretty popular practice in PrestaShop modules)._

To check current PrestaShop installation progress run `docker logs [your container hash for PrestaShop]` *(hash can be found manually using `docker ps` command)*.

Your PrestaShop will be built in the [./builds](./builds) directory under the name _./builds/prestashop\_{SPECIFIED_VERSION}_ for example _./builds/prestashop_1.7.8.8_

## Environment variables

Sometimes you may need to adjust some additional environment parameters, you can do it by modifying **.env** file inside your built PrestaShop _(i.e. ./builds/prestashop_1.7.8.8/.env)_ and rebuilding the environment using i.e. `bin/dev.sh up 1.7.8.8`

| **Argument**         | **Description**                 | **Default**             |
|----------------------|---------------------------------|-------------------------|
| _PRESTASHOP_VERSION_ | PrestaShop version to use       | _1.7.8.8_               |
| _MARIADB_VERSION_    | MariaDB version to use          | _10.6_                  |
| _PHPMYADMIN_VERSION_ | phpMyAdmin version to use       | _5.2_                   |
| _MAILHOG_VERSION_    | MailHog version to use          | _1.0.1_                 |
| _DB_SERVER_          | MariaDB hostname                | _mysql_                 |
| _DB_USER_            | MariaDB username                | _prestashop_            |
| _DB_PASSWD_          | MariaDB username password       | _prestashop_            |
| _DB_NAME_            | MariaDB database name           | _prestashop_            |
| _PS_INSTALL_AUTO_    | PrestaShop auto installation    | _1_                     |
| _PS_FOLDER_INSTALL_  | PrestaShop install directory    | _install-dev_           |
| _PS_FOLDER_ADMIN_    | PrestaShop admin directory      | _admin-dev_             |
| _PS_DOMAIN_          | PrestaShop domain               | _localhost:8080_        |
| _PS_COUNTRY_         | PrestaShop default country      | _pl_                    |
| _PS_LANGUAGE_        | PrestaShop default language     | _pl_                    |
| _PS_DEV_MODE_        | PrestaShop dev mode             | _0_                     |
| _PS_ADMIN_MAIL_      | PrestaShop administrator e-mail | _support@presta.expert_ |
| _PS_ADMIN_PASSWD_    | PrestaShop administrator e-mail | _presta.expert_         |

## Supported versions / tags

You can use any tag from the official PrestaShop Docker Hub [https://hub.docker.com/r/prestashop/prestashop/tags](https://hub.docker.com/r/prestashop/prestashop/tags), similarly you can specify custom tag for:
- MariaDB - [https://hub.docker.com/_/mariadb/tags](https://hub.docker.com/_/mariadb/tags)
- phpMyAdmin - [https://hub.docker.com/_/phpmyadmin/tags](https://hub.docker.com/_/phpmyadmin/tags)
- MailHog - [https://hub.docker.com/r/mailhog/mailhog/tags](https://hub.docker.com/r/mailhog/mailhog/tags)

### Examples
```bash
bin/dev.sh up 1.6.1.8
bin/dev.sh up 1.5.6.3
bin/dev.sh up 8.0.0-7.4-apache
```

You can also change version of the other services by modifying **.env** file inside your already built PrestaShop _(i.e. ./builds/prestashop_1.7.8.8/.env):_
```dotenv
# Custom phpmyadmin and mailhog versions
PHPMYADMIN_VERSION=5.1
MAILHOG_VERSION=1.0.0
```
_NOTE: We do not recommend downgrading the MariaDB version due to possible compatibility issues with database files previously created (db-data volume). If you absolutely need a different version of MariaDB set it manually in [./src/.env](./src/.env) before building PrestaShop._

Don't forget to rebuild your environment after above change using i.e. `bin/dev.sh up 1.7.8.8`

## Custom php.ini entries
Our dev environment also includes support for creating and overwriting entries from **php.ini**.

To set your own entries just edit the **php.ini** file in the _.docker/config_ directory inside your built PrestaShop _(i.e. ./builds/prestashop_1.7.8.8/.docker/config/php.ini)_ and rebuild the environment using i.e. `bin/dev.sh build 1.7.8.8 && bin/dev.sh up 1.7.8.8`

Several entries are already automatically added to each build:
```ini
; Come on... we are parsing a lot of data sometimes
max_execution_time = 0
memory_limit = 256M

; Modules or themes can be pretty big sometimes
upload_max_filesize = 128M
post_max_size = 128M

; Translation feature in older versions of PrestaShop can exceed default limit
max_input_vars = 10000

; Make MailHog work by default with PrestaShop
sendmail_path = /usr/local/bin/mhsendmail
```

## Authors

- [Presta.Expert](https://presta.expert) Team

## License

The files in this archive are released under the [MIT LICENSE](LICENSE).
