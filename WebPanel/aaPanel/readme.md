<body>
<div class="code-title">
<h3>Index</h3>
<div class="code-list">
<ul>
<li><a href="#install">Installaiton</a></li>
<li><a href="#main">Management</a></li>
<li><a href="#nginx">Nginx</a></li>
<li><a href="#apache">Apache</a></li>
<li><a href="#mysql">MySQL</a></li>
<li><a href="#ftp">FTP</a></li>
<li><a href="#php">PHP</a></li>
<li><a href="#redis">Redis</a></li>
<li><a href="#memcached">Memcached</a></li>
</ul>
</div>
</div>
________________________________________________________
<div class="codebanner">
<div class="title">aaPanel Linux script reference</div>
</div>
<div class="function">
<div class="layout">
<a name="install"></a>
<h2 class="th2">Installation</h2>
<div class="btcode" id="invite_code">
<span>Centos Installation</span>
<pre><code>yum install -y wget &amp;&amp; wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh &amp;&amp; bash install.sh aapanel</code></pre>
<span>Ubuntu/Deepin Installation</span>
<pre><code>wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh &amp;&amp; sudo bash install.sh aapanel</code></pre>
<span>Debian Installation</span>
<pre><code>wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh &amp;&amp; bash install.sh aapanel</code></pre>
<span>Fedora Installation</span>
<pre><code>yum install -y wget &amp;&amp; wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh &amp;&amp; bash install.sh aapanel</code></pre>
</div>
<a name="main"></a>
<h2 class="th2">Management</h2>
<div class="btcode">
<span>Stop</span>
<pre><code>service bt stop</code></pre>
<span>Start</span>
<pre><code>service bt start</code></pre>
<span>Restart</span>
<pre><code>service bt restart</code></pre>
<span>Uninstall</span>
<pre><code>service bt stop &amp;&amp; chkconfig --del bt &amp;&amp; rm -f /etc/init.d/bt &amp;&amp; rm -rf /www/server/panel</code></pre>
<span>View current port of control panel</span>
<pre><code>cat /www/server/panel/data/port.pl</code></pre>
<span>Change port of control panel，e.g. 8881（centos 6 Operation System）</span>
<pre><code>echo '8881' &gt; /www/server/panel/data/port.pl &amp;&amp; service bt restart
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 8881 -j ACCEPT
service iptables save
service iptables restart</code></pre>
<span>Change port of control panel，e.g. 8881（centos 7 Operation System）</span>
<pre><code>echo '8881' &gt; /www/server/panel/data/port.pl &amp;&amp; service bt restart
firewall-cmd --permanent --zone=public --add-port=8881/tcp
firewall-cmd --reload</code></pre>
<span>Force to change MySQL manager (root) Password，e.g. 123456</span>
<pre><code>cd /www/server/panel &amp;&amp; python tools.py root 123456</code></pre>
<span>Change control Panel login password，e.g. 123456</span>
<pre><code>cd /www/server/panel &amp;&amp; python tools.py panel 123456</code></pre>
<span>Site Configuration location</span>
<pre><code>/www/server/panel/vhost</code></pre>
<span>Delete banding domain of control panel</span>
<pre><code>rm -f /www/server/panel/data/domain.conf</code></pre>
<span>Clean login restriction</span>
<pre><code>rm -f /www/server/panel/data/*.login</code></pre>
<span>View control panel authorization IP</span>
<pre><code>cat /www/server/panel/data/limitip.conf</code></pre>
<span>Stop access restriction</span>
<pre><code>rm -f /www/server/panel/data/limitip.conf</code></pre>
<span>View permission domain</span>
<pre><code>cat /www/server/panel/data/domain.conf</code></pre>
<span>Turn off control panel SSL</span>
<pre><code>rm -f /www/server/panel/data/ssl.pl &amp;&amp; /etc/init.d/bt restart</code></pre>
<span>View control panel error logs</span>
<pre><code>cat /tmp/panelBoot</code></pre>
<span>View database error log</span>
<pre><code>cat /www/server/data/*.err</code></pre>
<span>Site Configuration directory(nginx)</span>
<pre><code>/www/server/panel/vhost/nginx</code></pre>
<span>Site Configuration directory(apache)</span>
<pre><code>/www/server/panel/vhost/apache</code></pre>
<span>Site default directory</span>
<pre><code>/www/wwwroot</code></pre>
<span>Database backup directory</span>
<pre><code>/www/backup/database</code></pre>
<span>Site backup directory</span>
<pre><code>/www/backup/site</code></pre>
<span>Site logs</span>
<pre><code>/www/wwwlogs</code></pre>
</div>
<a name="nginx"></a>
<h2 class="th2">Nginx</h2>
<div class="btcode">
<span>nginx installation directory</span>
<pre><code>/www/server/nginx</code></pre>
<span>Start</span>
<pre><code>service nginx start</code></pre>
<span>Stop</span>
<pre><code>service nginx stop</code></pre>
<span>Restart</span>
<pre><code>service nginx restart</code></pre>
<span>Reload</span>
<pre><code>service nginx reload</code></pre>
<span>nginx Configuration</span>
<pre><code>/www/server/nginx/conf/nginx.conf</code></pre>
</div>
<a name="apache"></a>
<h2 class="th2">Apache</h2>
<div class="btcode">
<span>apache installation directory</span>
<pre><code>/www/server/httpd</code></pre>
<span>Start</span>
<pre><code>service httpd start</code></pre>
<span>Stop</span>
<pre><code>service httpd stop</code></pre>
<span>Restart</span>
<pre><code>service httpd restart</code></pre>
<span>Reload</span>
<pre><code>service httpd reload</code></pre>
<span>apache Configuration</span>
<pre><code>/www/server/apache/conf/httpd.conf</code></pre>
</div>
<a name="mysql"></a>
<h2 class="th2">MySQL</h2>
<div class="btcode">
<span>mysql  installation directory</span>
<pre><code>/www/server/mysql</code></pre>
<span>phpmyadmin installation directory</span>
<pre><code>/www/server/phpmyadmin</code></pre>
<span>Data storage directory</span>
<pre><code>/www/server/data mysql</code></pre>
<span>Start</span>
<pre><code>service mysqld start</code></pre>
<span>Stop</span>
<pre><code>service mysqld stop</code></pre>
<span>Restart</span>
<pre><code>service mysqld restart</code></pre>
<span>Reload</span>
<pre><code>service mysqld reload</code></pre>
<span>mysql Configuration</span>
<pre><code>/etc/my.cnf</code></pre>
</div>
<a name="ftp"></a>
<h2 class="th2">FTP</h2>
<div class="btcode">
<span>ftp installation directory</span>
<pre><code>/www/server/pure-ftpd</code></pre>
<span>Start</span>
<pre><code>service pure-ftpd start</code></pre>
<span>Stop</span>
<pre><code>service pure-ftpd stop</code></pre>
<span>Restart</span>
<pre><code>service pure-ftpd restart</code></pre>
<span>ftp Configuration</span>
<pre><code>/www/server/pure-ftpd/etc/pure-ftpd</code></pre>
</div>
<a name="php"></a>
<h2 class="th2">PHP</h2>
<div class="btcode">
<span>php installation directory</span>
<pre><code>/www/server/php</code></pre>
<span>Start</span><span class="info">(Please modify by PHP version, e.g. service php-fpm-54 start)</span>
<pre><code>servicephp-fpm-{52|53|54|55|56|70|71} start</code></pre>
<span>Stop</span><span class="info">(Please modify by PHP version, e.g. service php-fpm-54 stop)</span>
<pre><code>service php-fpm-{52|53|54|55|56|70|71} stop</code></pre>
<span>Restart</span><span class="info">(Please modify by PHP version, e.g. service php-fpm-54 restart)</span>
<pre><code>service php-fpm-{52|53|54|55|56|70|71} restart</code></pre>
<span>Reload</span><span class="info">(Please modify by PHP version, e.g. service php-fpm-54 reload)</span>
<pre><code>service php-fpm-{52|53|54|55|56|70|71} reload</code></pre>
<span> Configuration</span><span class="info">(Please modify by PHP version, e.g. /www/server/php/52/etc/php.ini)</span>
<pre><code>/www/server/php/{52|53|54|55|56|70|71}/etc/php.ini</code></pre>
</div>
<a name="redis"></a>
<h2 class="th2">Redis</h2>
<div class="btcode">
<span>redis installation directory</span>
<pre><code>/www/server/redis</code></pre>
<span>Start</span>
<pre><code>service redis start</code></pre>
<span>Stop</span>
<pre><code>service redis stop</code></pre>
<span>redis Configuration</span>
<pre><code>/www/server/redis/redis.conf</code></pre>
</div>
<a name="memcached"></a>
<h2 class="th2">Memcached</h2>
<div class="btcode">
<span>memcached installation directory</span>
<pre><code>/usr/local/memcached</code></pre>
<span>Start</span>
<pre><code>service memcached start</code></pre>
<span>Stop</span>
<pre><code>service memcached stop</code></pre>
<span>Restart</span>
<pre><code>service memcached restart</code></pre>
<span>Reload</span>
<pre><code>service memcached reload</code></pre>
</div>
</div>
</div>
</body>
