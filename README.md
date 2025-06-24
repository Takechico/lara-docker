# Lara-docker

This repository shows how you can organize a Laravel project with Docker and all the extra tools you might need for a real-world application.

---

## 🚀 What’s Inside

- **Nginx Configuration**
  * Example Nginx settings for serving your Laravel application. Place your custom configs in the nginx/ directory and mount them into your container as needed.
- **PostgreSQL & MSSQL Drivers**
  * The Docker image is prepared to install both PostgreSQL and MSSQL drivers. This allows your Laravel app to connect to external PostgreSQL or MSSQL databases by simply configuring your .env
- **Supervisor Setup**
  * Includes a sample supervisord.conf for running background processes such as php artisan queue:work or php artisan horizon. You can adjust the configuration to manage any additional Laravel workers you require
- **cron Configuration**
  * Provides a custom crontab file and Docker instructions for running Laravel's scheduled tasks (php artisan schedule:run) every minute. This ensures your scheduled jobs are executed automatically inside the container
- **Horizon**
  * Horizon Configuration
  Example Supervisor and environment settings for running Laravel Horizon, giving you a dashboard and process manager for your queues.

---

## 🛠️ How to Use

- This repo is just a configuration example.
- Copy the files or use them as a reference for your own project.
- Adjust paths, environment variables, and settings to fit your needs.

---

## 📁 Main Files
| File/Folder                              | Purpose                                                    |
|:-----------------------------------------|:-----------------------------------------------------------|
| `docker-compose.yml`                     | Defines services (app, redis)                              |
| `Dockerfile`                             | Sets up PHP and all needed extensions                      |
| `conf.d/nginx/`                          | Nginx configuration files                                  |
| `conf.d/supervisor/supervisord.conf`     | Supervisor config for running queue workers, Horizon, etc. |
| `conf.d/php/php.ini`                     | Custom PHP configuration (memory limit, extensions, etc.)  |
| `conf.d/php-fpm/php-fpm.conf`            | PHP-FPM process manager settings                           |

---

## 🧩 Example: Adding Supervisor and cron

- **Supervisor** runs background processes like
  `php artisan queue:work` or `php artisan horizon` automatically.
- **cron** runs Laravel's scheduled tasks every minute using
  `php artisan schedule:run`.

---

## 💡 Quick Notes

- Use this as a starting point for your own Laravel Docker setup.
- You’ll need to add your own Laravel code and adjust the configs.
- This is for local development and learning, **not for production use**.

