Scripts for generating webp images, as well as incremental generation. Designed for magento2 projects.

<h2>Installation :</h2>

<h3>It is necessary to add files to the correct directory</h3>
By default [m2-root]/scripts.
And you also need to set the execution rights

<h3>Magento 2 settings</h3>
It is also necessary to set the corresponding configuration in M2 (in order to add the resize parameters to the URL instead of the link to the cached file resize).

```
bin/magento config:set web/url/catalog_media_url_format image_optimization_parameters && \
bin/magento cache:clean
```

<h3>Server configurations</h3>
The example for warden is in the m2-warden directory of the repository

<h4>For nginx</h4>

```
# create cache for resized images
proxy_cache_path /tmp/nginx-catalog-media-cache/
    levels=1:2
    keys_zone=catalog_media:10m
    inactive=24h
    max_size=500m;

# declare resize streams for legacy and new browsers
map $http_accept $image_resize_stream {
    default image_resize_legacy;
    ~image/webp image_resize_webp;
}

upstream image_resize_webp {
    server localhost:20001;
}

upstream image_resize_legacy {
    server localhost:20002;
}

# server for modern browsers
server {
    server_name localhost;
    listen 20001;

    root /var/www/html/pub;
    set $MAGE_ROOT /var/www/html;

    location ~* ^/(?<path>media/catalog/.*)$ {
        set $ext "";

        # when request is made for image.jpg,
        # check if image.jpg.webp is available.
        if (-f $MAGE_ROOT/pub/$path.webp) {
            set $ext .webp;
        }

        alias $MAGE_ROOT/pub/$path$ext;

        set $width "-";
        set $height "-";
        if ($arg_width != '') {
            set $width $arg_width;
        }
        if ($arg_height != '') {
            set $height $arg_height;
        }

        image_filter resize $width $height;
        image_filter_interlace on;
        image_filter_jpeg_quality 75;
        image_filter_webp_quality 75;
    }
}

# server for legacy browsers
server {
    server_name localhost;
    listen 20002;

    root /var/www/html/pub;

    location / {
        set $width "-";
        set $height "-";
        if ($arg_width != '') {
            set $width $arg_width;
        }
        if ($arg_height != '') {
            set $height $arg_height;
        }

        image_filter resize $width $height;
        image_filter_interlace on;
        image_filter_jpeg_quality 75;
        image_filter_webp_quality 75;
    }
}
```

```
location /media/ {
    location ~* ^/media/catalog/.* {
        proxy_pass http://$image_resize_stream;
        proxy_cache catalog_media;
        proxy_cache_valid 200 24h;
    }
```
<h2>Run scripts</h2>
`./webp-convert-all.sh  - Conversion of all pictures.

./webp-remove-all.sh - Deletion of all converted images via the script

<h3>Logs</h3>
Logs will be available in [m2-root]/var/log/[webp.info.log|webp.error.log]

<h3>Continuous execution</h3>
It is also suggested to add webp-convert-all script to crontab to automatically generate new images

<h2>Docs</h2>
<p>https://breezefront.com/docs/next-gen-images</p>
<p>https://experienceleague.adobe.com/en/docs/commerce-operations/configuration-guide/storage/remote-storage/remote-storage-image-resize</p>
