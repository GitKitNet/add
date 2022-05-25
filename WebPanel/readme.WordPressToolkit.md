WHM Marketplace
## Note:
You must be root-enabled to access the WHM Marketplace interface (WHM >> Home >> Server Configuration >> WHM Marketplace).

To install the WordPress Toolkit plugin in the WHM Marketplace interface (WHM >> Home >> Server Configuration >> WHM Marketplace), perform the following steps:

Navigate to the WHM Marketplace interface (WHM >> Home >> Server Configuration >> WHM Marketplace).
Locate the WordPress Toolkit listing under Add Extensions and click Install.

# Manual installation
To install the WordPress Toolkit plugin on the command line, run the following command as the root user:

<code><pre>
sh <(curl https://wp-toolkit.plesk.com/cPanel/installer.sh || wget -O - https://wp-toolkit.plesk.com/cPanel/installer.sh)

</pre></code>

# Uninstall WordPress Toolkit
To uninstall the WordPress Toolkit plugin on the command line, run the following command as the root user:
<code><pre>
rpm -e wp-toolkit-cpanel

</pre></code>
Manage account access
To manage account access to the WordPress Toolkit or WordPress Toolkit Deluxe feature, use the following interfaces:

WHM’s Feature Manager interface (WHM >> Home >> Packages >> Feature Manager >> Feature Lists) lets you manage the features your feature lists.

Important:
Server administrators must enable the following features to allow users access the WordPress Toolkit interface:

WordPress Toolkit
MySQL
Subdomains
MIME Types
Cronjobs
Directory Privacy
Password & Security
File Manager
Redirects
The WordPress Toolkit Deluxe feature requires the WordPress Toolkit and WordPress Toolkit Deluxe features.

WHM’s Edit a Package interface (WHM >> Home >> Packages >> Edit a Package) lets you manage the feature list that existing packages use.

WHM’s Add a Package interface (WHM >> Home >> Packages >> Add a Package) lets you create a new package with new feature lists. Use this interface if you plan to offer new packages to customers and resellers with these WordPress Toolkit features.

WHM’s Modify an Account interface (WHM >> Home >> Account Functions >> Modify an Account) lets you change the package that each account uses.

Note:
We recommend that you create and use a package for the WordPress Toolkit feature and a similar package for the WordPress Toolkit Deluxe feature.


# Updates to WordPress Toolkit
Updates to the WordPress Toolkit run nightly.

To check the system’s auto-update status, run the following command:
<code><pre>
systemctl status wp-toolkit-scheduled-tasks
</pre></code>

To force an auto-update run, run the following command:

<code><pre>
su wp-toolkit --shell=/bin/bash -c `/usr/bin/sw-engine -d auto_prepend_file=/usr/local/cpanel/3rdparty/wp-toolkit scripts/scheduled-task-prepend-file.php /usr/local/cpanel/3rdparty/wp-toolkit/plib/scripts/instances-auto-update.php`
</pre></code>

Troubleshoot WordPress Toolkit
The log files for the WordPress Toolkit reside in the /usr/local/cpanel/3rdparty/wp-toolkit/var/logs/ directory.

To troubleshoot the WordPress Toolkit, run the following command, where filename represents the log file’s name:
<code><pre>
grep -A1 ERROR /usr/local/cpanel/3rdparty/wp-toolkit/var/logs/filename.log
</pre></code>
You can also enable enhanced logging to debug and troubleshoot the WordPress Toolkit. To do this, add the following line to the /usr/local/cpanel/3rdparty/wp-toolkit/var/etc/config.ini file:
<code><pre>
logCommandsAndFileOperations = true
</pre></code>
 
  
  
