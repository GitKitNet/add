-- phpMyAdmin SQL Dump
-- version 4.0.8
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: May 12, 2014 at 10:11 AM
-- Server version: 5.1.71
-- PHP Version: 5.3.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `root_cwp`
--
CREATE DATABASE `root_cwp` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `root_cwp`;
-- --------------------------------------------------------

--
-- Table structure for table `backups`
--

CREATE TABLE IF NOT EXISTS `backups` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `backup_enable` varchar(5) NOT NULL,
  `backup_location` varchar(60) NOT NULL,
  `backup_daily` varchar(5) NOT NULL,
  `backup_weekly` varchar(5) NOT NULL,
  `backup_monthly` varchar(5) NOT NULL,
  `backup_mysql` varchar(5) NOT NULL,
  `backup_vmail` varchar(5) NOT NULL,
  `backup_all` varchar(5) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `backups`
--

INSERT INTO `backups` (`id`, `backup_enable`, `backup_location`, `backup_daily`, `backup_weekly`, `backup_monthly`, `backup_mysql`, `backup_all`) VALUES
(1, 'on', '/backup', 'on', 'on', 'on', 'on', 'off');

-- --------------------------------------------------------

--
-- Table structure for table `nameserver`
--

CREATE TABLE IF NOT EXISTS `nameserver` (
  `id` int(40) NOT NULL,
  `ns1_name` varchar(255) NOT NULL,
  `ns1_ip` varchar(50) NOT NULL,
  `ns2_name` varchar(255) NOT NULL,
  `ns2_ip` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `nameserver`
--

INSERT INTO `nameserver` (`id`, `ns1_name`, `ns1_ip`, `ns2_name`, `ns2_ip`) VALUES
(1, 'ns1.centos-webpanel.com', '127.0.0.1', 'ns2.centos-webpanel.com', '127.0.0.1');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(255) NOT NULL,
  `shortjob` text NOT NULL,
  `description` text NOT NULL,
  `link` varchar(255) NOT NULL,
  `readed` varchar(255) NOT NULL,
  `completed` varchar(255) NOT NULL,
  `date` datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `packages`
--

CREATE TABLE IF NOT EXISTS `packages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `package_name` varchar(255) NOT NULL,
  `disk_quota` varchar(40) NOT NULL,
  `bandwidth` varchar(40) NOT NULL,
  `ftp_accounts` varchar(40) NOT NULL,
  `email_accounts` varchar(40) NOT NULL,
  `email_lists` varchar(40) NOT NULL,
  `databases` varchar(40) NOT NULL,
  `sub_domains` varchar(40) NOT NULL,
  `parked_domains` varchar(40) NOT NULL,
  `addons_domains` varchar(40) NOT NULL,
  `hourly_emails` varchar(40) NOT NULL,
  `reseller` varchar(40) NOT NULL,
  `accounts` varchar(40) NOT NULL,
  `cgroups` varchar(255) NULL DEFAULT NULL,
  `nproc` varchar(40) NOT NULL DEFAULT '40',
  `apache_nproc` varchar(40) NOT NULL DEFAULT '40',
  `inode` varchar(40) NOT NULL DEFAULT '0',
  `nofile` varchar(40) NOT NULL DEFAULT '150',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `packages`
--

INSERT INTO `packages` (`id`, `package_name`, `disk_quota`, `bandwidth`, `ftp_accounts`, `email_accounts`, `email_lists`, `databases`, `sub_domains`, `parked_domains`, `addons_domains`, `hourly_emails`) VALUES
(1, 'default', '20000', '100000', '10', '10', '10', '10', '10', '10', '10', '200');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE IF NOT EXISTS `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login_type` varchar(40) NOT NULL,
  `ssh_port` varchar(40) NOT NULL,
  `root_name` varchar(7) NOT NULL,
  `root_email` varchar(255) NOT NULL,
  `apache_port` varchar(5) NOT NULL,
  `homedir` varchar(200) NOT NULL,
  `mysql_pwd` varchar(40) NOT NULL,
  `apache_vhost_tpl` text NOT NULL,
  `apache_sub_vhost_tpl` text NOT NULL,
  `named_tpl` text NOT NULL,
  `dns_zone_tpl` text NOT NULL,
  `shared_ip` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'ssh','22','root','my@email.com','80','/home','','# vhost_start %domain_name%\r\n<VirtualHost %domain_ip%:%domain_port%>\r\nServerName %domain_name%\r\nServerAlias www.%domain_name%\r\nServerAdmin %admin_email%\r\nDocumentRoot \"%homedir%/%username%/public_html\"\r\nScriptAlias /cgi-bin/ \"%homedir%/%username%/public_html/cgi-bin/\r\n# \r\n# Custom settings are loaded below this line (if any exist)\r\n# Include \"/usr/local/apache/conf/userdata/%username%/%domain_name%/*.conf\r\n\r\n<IfModule mod_suexec.c>\r\n        SuexecUserGroup %username% %username%\r\n</IfModule>\r\n\r\n<IfModule mod_suphp.c>\r\n        suPHP_UserGroup %username% %username%\r\n        suPHP_ConfigPath /home/%username%\r\n</IfModule>\r\n\r\n<Directory \"%homedir%/%username%/public_html\">\r\n        AllowOverride All\r\n</Directory>\r\n\r\n</VirtualHost>\r\n# vhost_end %domain_name%','# vhost_start %domain_name%\r\n<VirtualHost %domain_ip%:%domain_port%>\r\nServerName %domain_name%\r\nServerAlias www.%domain_name%\r\nServerAdmin %admin_email%\r\nDocumentRoot \"%path%\"\r\nScriptAlias /cgi-bin/ %path%/cgi-bin/\r\n# \r\n# Custom settings are loaded below this line (if any exist)\r\n# Include \"/usr/local/apache/conf/userdata/%username%/%domain_name%/*.conf\r\n\r\n<IfModule mod_suexec.c>\r\n        SuexecUserGroup %username% %username%\r\n</IfModule>\r\n\r\n<IfModule mod_suphp.c>\r\n        suPHP_UserGroup %username% %username%\r\n</IfModule>\r\n\r\n<Directory \"%path%\">\r\n        AllowOverride All\r\n</Directory>\r\n\r\n</VirtualHost>\r\n# vhost_end %domain_name%','// zone %domain%\r\nzone \"%domain%\" {\r\n                                   type master;\r\n                                        file \"/var/named/%domain%.db\";};\r\n// zone_end %domain%','; Panel %version%\r\n; Zone file for %domain%\r\n$TTL 14400\r\n%domain%.      86400        IN      SOA     %nameserver%. %rpemail%. (\r\n         2013071600      ; serial, todays date+todays\r\n                86400           ; refresh, seconds\r\n          7200            ; retry, seconds\r\n            3600000         ; expire, seconds\r\n           86400 )         ; minimum, seconds\r\n\r\n%domain%. 86400 IN NS %nameserver%.\r\n%domain%. 86400 IN NS %nameserver2%.\r\n\r\n%domain%. IN A %ip%\r\n\r\nlocalhost.%domain%. IN A 127.0.0.1\r\n\r\n%domain%. IN MX 0 %domain%.\r\n\r\nmail IN CNAME %domain%.\r\nwww IN CNAME %domain%.\r\nftp IN CNAME %domain%.\r\n; Add additional settings below this line','127.0.0.1');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subdomains`
--

CREATE TABLE IF NOT EXISTS `subdomains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subdomain` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `user` varchar(40) NOT NULL,
  `path` varchar(255) NOT NULL,
  `setup_time` datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(40) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `ip_address` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `setup_date` datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  `package` varchar(40) NOT NULL,
  `backup` varchar(40) NOT NULL,
  `reseller` varchar(40) NOT NULL,
  `last_access` datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  `bandwidth` varchar(40) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `domains`
--

CREATE TABLE IF NOT EXISTS `domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) NOT NULL,
  `user` varchar(40) NOT NULL,
  `path` varchar(255) NOT NULL,
  `setup_time` datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

