# Nginx for PHP on Wodby

What this service adds to the Nginx service it is based on: it serves a PHP application's static files and passes everything else to the linked PHP service.

## How requests are handled

The service sets `NGINX_VHOST_PRESET` to `php`:

- A request for an existing file under the document root is served by Nginx.
- Any other path is handed to the front controller (`NGINX_FASTCGI_INDEX`, normally `index.php`) with the query string, so the application needs no rewrite rules of its own. `.htaccess` files are not read.
- A path with a static file extension (`NGINX_STATIC_EXT_REGEX`) that matches no file returns 404 without reaching PHP. Set `NGINX_STATIC_404_TRY_INDEX` when the application generates such paths itself.
- `.php` requests go to the PHP service over FastCGI.

## Backend link

The required backend link must point to a PHP-FPM service. It sets `NGINX_BACKEND_HOST` and `NGINX_BACKEND_PORT`, which form the FastCGI upstream.

Nginx passes the script as a path under its own document root, so the PHP service must have the code at the same path. Both images are built from the same source for that reason: this service has no repository of its own and is built from the source of the linked PHP service, copied to `/var/www/html`.

PHP receives `HTTPS` from the `X-Forwarded-Proto` header, so the application sees the original scheme.

## Document root

The `docroot` setting (variable `DOCROOT_SUBDIR`) defaults to `public`. `NGINX_SERVER_ROOT` is `/var/www/html/` followed by it. It must be the directory that holds the front controller.

## Variables that matter most

In addition to those of the Nginx service: `NGINX_FASTCGI_READ_TIMEOUT` (how long Nginx waits for PHP), `NGINX_FASTCGI_BUFFERS` and `NGINX_FASTCGI_BUFFER_SIZE`, `NGINX_FASTCGI_INDEX`, `NGINX_STATIC_404_TRY_INDEX`. Upload size is limited both here (`NGINX_CLIENT_MAX_BODY_SIZE`) and by the PHP service's own settings.

## Static files

Static files are served from the built image: a changed asset needs a new build and deployment of this service.

In a development workspace, the document root subdirectory of the checkout is mounted into this service read-only, so an edited or newly built asset is served without a build or deployment. Nginx cannot write there.

## Check the result

- `nginx -T` shows the upstream and the document root in effect.
- `curl -sI localhost/` from inside the container returns the application's response when the PHP service is reachable.
