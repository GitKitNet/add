#!/bin/bash

echo -e "Start install plugins for WordPress"
PLUGINS_WP=""


# installing plugin:
wp plugin install woocommerce

# activating plugin:
wp plugin activate woocommerce
