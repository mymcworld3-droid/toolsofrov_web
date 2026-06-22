# 考慮到 Silex 2.0 的相容性，建議使用 PHP 7.4 搭配 Apache
FROM php:7.4-apache

# 安裝系統必要套件與 PHP 擴充模組
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip

# 啟用 Apache 的 mod_rewrite 模組 (提供路由轉址使用)
RUN a2enmod rewrite

# 將 Apache 的 DocumentRoot 變更為 web/ 目錄
ENV APACHE_DOCUMENT_ROOT /var/www/html/web

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 下載並安裝 Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 將專案內所有檔案複製到容器中
COPY . /var/www/html/

# 執行 Composer 安裝依賴套件 (會自動忽略 require-dev 中的 Heroku 相關套件)
RUN composer install --no-dev --optimize-autoloader

# 調整目錄權限，讓 Apache 擁有適當讀寫權限
RUN chown -R www-data:www-data /var/www/html
