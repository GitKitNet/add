Index: scripts/auto-install.php
===================================================================
RCS file: scripts/auto-install.php
diff -N scripts/auto-install.php
--- /dev/null	1 Jan 1970 00:00:00 -0000
+++ scripts/auto-install.php	1 Jan 1970 00:00:00 -0000
@@ -0,0 +1,172 @@
+<?php
+// $Id$
+/**
+ * @file
+ * Install Drupal from the command line.
+ */
+
+/**
+ * Root directory of Drupal installation.
+ */
+define('DRUPAL_ROOT', realpath(dirname(realpath(__FILE__)) . '/..'));
+chdir(DRUPAL_ROOT);
+
+$args = auto_install_parse_args();
+//print_r($args);
+
+if (($error = auto_install_check_args($args)) === TRUE) {
+  auto_install_install();
+}
+else {
+  echo "\nERROR: $error\n";
+  auto_install_help();
+}
+echo "\n";
+
+/**
+ * Print help text.
+ */
+function auto_install_help() {
+  global $args;
+
+  echo <<<EOF
+
+Install Drupal from the command line.
+
+Usage:        {$args['script']} [OPTIONS] -url=[URL] -db=[DB_NAME] -user=[DB_USER] -pass=[DB_PASS] site
+Example:      {$args['script']} -url=http://localhost -db=drupal-7 -user=drupal -pass=password default
+
+EOF;
+}
+
+/**
+ * Parse the arguments and return a formatted array.
+ *
+ * @return
+ *   Array of formatted arguments.
+ */
+function auto_install_parse_args() {
+  $args = array();
+  $args['script'] = array_shift($_SERVER['argv']);
+
+  foreach ($_SERVER['argv'] as $arg) {
+    if (preg_match('/--(\S+)=(.*)/', $arg, $match)) {
+      $args[$match[1]] = $match[2];
+    }
+    else if ($arg{0} == '-') {
+      $args[substr($arg, 1)] = TRUE;
+    }
+    else {
+      $args['site'] = $arg;
+      break;
+    }
+  }
+
+  return $args;
+}
+
+/**
+ * Ensure that the arguments are valid.
+ *
+ * @param $args
+ *   Array of formatted arguments.
+ * @return
+ *   TRUE if arguments are valid, or error message.
+ */
+function auto_install_check_args($args) {
+  $required = array('site', 'url', 'db', 'user', 'pass');
+  foreach ($required as $require) {
+    if (!isset($args[$require])) {
+      return "missing '$require' argument.";
+    }
+  }
+  return TRUE;
+}
+
+function auto_install_install() {
+  global $args;
+
+  echo "\nInitializing install process...\n";
+  $_SERVER['HTTP_HOST'] = 'default';
+  $_SERVER['HTTP_USER_AGENT'] = 'auto-install script';
+  $_SERVER['PHP_SELF'] = '/index.php';
+  $_SERVER['REMOTE_ADDR'] = '127.0.0.1';
+  $_SERVER['SERVER_SOFTWARE'] = 'PHP CLI';
+  $_SERVER['REQUEST_METHOD'] = 'GET';
+  $_SERVER['QUERY_STRING'] = '';
+  $_SERVER['PHP_SELF'] = $_SERVER['REQUEST_URI'] = '/';
+
+  if (auto_install_copy_settings($args['site'])) {
+    echo " > Bootstrapping Drupal...\n";
+    require_once DRUPAL_ROOT . '/includes/bootstrap.inc';
+    drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
+
+    echo " > Starting installation...\n";
+    auto_install_run($args['db'], $args['user'], $args['pass'], $args['prefix'] ? $args['prefix'] : '');
+  }
+  else {
+    echo "ERROR: failed to copy settings file. (check permisions to sites folder)\n";
+  }
+}
+
+/**
+ * Make a copy of the settings file to ensure there is no permission issue.
+ *
+ * @param $site
+ *   Site folder name.
+ * @return
+ *   Boolean success.
+ */
+function auto_install_copy_settings($site) {
+  $default_settings = './sites/default/default.settings.php';
+  $settings = "./sites/$site/settings.php";
+  echo " > Copying $default_settings to $settings...\n";
+  return @copy($default_settings, $settings);
+}
+
+function auto_install_run($db, $user, $pass, $prefix = '') {
+  module_load_include('php', 'simpletest', 'drupal_web_test_case');
+
+  // Install Drupal.
+  $d = new DrupalWebTestCase();
+
+  // Step: Select an installation profile.
+  // Step: Choose language.
+  $d->drupalGet('install.php', array('query' => 'profile=default&locale=en'));
+
+  return;
+
+  // Step: Database configuration.
+  $edit = array();
+  $edit['database'] = $db;
+  $edit['username'] = $user;
+  $edit['password'] = $pass;
+  $edit['db_prefix'] = '';
+  $d->drupalPost(NULL, $edit, t('Save and continue'));
+
+  // Step: Site configuration.
+  $edit = array();
+  $edit['site_name'] = 'checkout';
+  $edit['site_mail'] = 'admin@example.com';
+  $edit['account[name]'] = 'admin';
+  $edit['account[mail]'] = 'admin@example.com';
+  $edit['account[pass][pass1]'] = $pass = $d->randomName(12);
+  $edit['account[pass][pass2]'] = $pass;
+  $edit['clean_url'] = 0;
+  $edit['update_status_module[1]'] = FALSE;
+  $d->drupalPost(NULL, $edit, t('Save and continue'));
+
+  // Record password use later.
+  pifr_review_admin_pass($pass);
+
+  // Step: Finished.
+  $d->assertText(t('Drupal installation complete'));
+
+//  pifr_review_path(TRUE);
+
+  // Clear SimpleTest results.
+  simpletest_clean_results_table();
+
+  // Make sure that site installed correctly.
+  return ($d->_results['#exception'] + $d->_results['#fail']) == 0;
+}
