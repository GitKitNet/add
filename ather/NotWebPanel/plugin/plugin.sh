#!/bin/sh

#  bash <(curl -fsSL https://raw.githubusercontent.com/numbnet/WebPanel/master/NotWebPanel/plugin/plugin.sh)
#
#  Instant Wordpress!
#  ------------------
#  My script for installing the latest version of WordPress plus a number of plugins I find useful.
# 
#  To use this script, go to the directory you want to install Wordpress to in the terminal and run this command:
#

WPs="wordpress.org"
WPpl="downloads.${WPs}/plugin"
TMPWP=/temp/wpress
rm -rf ${TMPWP} && mkdir -p ${TMPWP} && cd ${TMPWP}
PLDIR=wordpress/wp-content/plugins/
mkdir -p ${PLDIR}

# Latest version of WP
echo "Fetching WordPress...";
wget --quiet ${WPs}/latest.zip && unzip -q latest.zip;

# All-in-One-SEO-Pack
echo "Fetching All-in-One-SEO-Pack plugin...";
wget --quiet ${WPpl}/all-in-one-seo-pack.zip && unzip -q all-in-one-seo-pack.zip && mv all-in-one-seo-pack ${PLDIR}

# Sitemap Generator
echo "Fetching Google Sitemap Generator plugin...";
wget --quiet ${WPpl}/google-sitemap-generator.zip && unzip -q  google-sitemap-generator.zip && mv google-sitemap-generator ${PLDIR}

# Secure WordPress
echo "Fetching Secure WordPress plugin...";
wget --quiet ${WPpl}/secure-wordpress.zip && unzip -q  secure-wordpress.zip && mv secure-wordpress ${PLDIR}

# Hierarchy Plugin
echo "Fetching Hierarchy plugin...";
wget --quiet ${WPpl}/hierarchy.zip && unzip -q  hierarchy.zip && mv hierarchy ${PLDIR}

# Image Widgets (Why isn't this standard?)
echo "Fetching Image Widget plugin...";
wget --quiet ${WPpl}/image-widget.zip && unzip -q  image-widget.zip && mv image-widget ${PLDIR}

# Super-cache
echo "Fetching Super Cache plugin...";
wget --quiet ${WPpl}/wp-super-cache.zip && unzip -q  wp-super-cache.zip && mv wp-super-cache ${PLDIR}

# W3 Total Cache (A little redundant with above, but I like options.)
echo "Fetching W3 Total Cache...";
wget --quiet ${WPpl}/w3-total-cache.zip && unzip -q  w3-total-cache.zip && mv w3-total-cache ${PLDIR}

# Register Plus Redux (Good for membership-style sites)echo "Fetching Register Plus Redux...";
wget --quiet ${WPpl}/register-plus-redux.zip && unzip -q register-plus-redux.zip && mv register-plus-redux ${PLDIR}

# Regenerate Thumbnails (good for when you need to make custom sizes)
echo "Fetching Regenerate Thumbnails...";
wget --quiet ${WPpl}/regenerate-thumbnails.zip && unzip -q regenerate-thumbnails.zip && mv regenerate-thumbnails ${PLDIR}

# Taxonomy Taxi
echo "Fetching Taxonomy Taxi...";
wget --quiet ${WPpl}/taxonomy-taxi.zip && unzip -q taxonomy-taxi.zip && mv taxonomy-taxi ${PLDIR}

# Custom Post Type UI
echo "Fetching Custom Post Type UI...";
wget --quiet ${WPpl}/custom-post-type-ui.zip && unzip -q custom-post-type-ui.zip && mv custom-post-type-ui ${PLDIR}

# WordPress Importer
echo "Fetching WordPress Importer...";
wget --quiet ${WPpl}/wordpress-importer.zip && unzip -q wordpress-importer.zip && mv wordpress-importer ${PLDIR}

# WP-Quick-Pages
echo "Fetching WP-Quick-Pages...";
wget --quiet ${WPpl}/wp-quick-pages.zip && unzip -q wp-quick-pages.zip && mv wp-quick-pages ${PLDIR}

# Simple Page Ordering
echo "Fetching Simple Page Ordering...";
wget --quiet ${WPpl}/simple-page-ordering.zip && unzip -q simple-page-ordering.zip && mv simple-page-ordering ${PLDIR}

# FeedWordPress
echo "FeedWordPress...";
wget --quiet ${WPpl}/feedwordpress.zip && unzip -q feedwordpress.zip && mv feedwordpress ${PLDIR}

# BackupWPup
echo "BackupWPup...";
wget --quiet ${WPpl}/backwpup.zip && unzip -q backwpup.zip && mv backwpup ${PLDIR}

# Options Framework
echo "Fetching Options Framework plugin..."
wget --quiet "${WPpl}/options-framework.zip" && unzip -q options-framework.zip && mv options-framework ${PLDIR}

# Meta
echo "Fetching Meta Box plugin..."
wget --quiet "${WPpl}/meta-box.zip" && unzip -q meta-box.zip && mv meta-box ${PLDIR}

# Move stuff into current directory
mv wordpress/* . 
sleep 10
rm -rf wordpress;

# Cleanupecho "Cleaning up temporary files and directories...";
rm *.zip
# Disable the built-in file editor because it's a hacking vector and I hate it
echo "Disabling file editor...";
echo -en "\n\n/* Disable the file editor */\n define(‘DISALLOW_FILE_EDIT’, true);" >> wp-config-sample.php

echo "Done!";

# exit 1
