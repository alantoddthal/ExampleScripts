#! /usr/bin/ksh

# /usr/local/adm/cycle_prod

# shutdown the Java Web Server (jws), apache, and then oracle
# next start up oracle, then apache and then jws

# Last Updated	By	Reason
# ------------	-------	----------------------
# 05/05/99	swalker	original release
# 05/25/99	swalker	updated for new production server
# 07/06/99	swalker	added lsof look for users

if [ `(id | cut -d\( -f1 | cut -d= -f2)` != 0 ]
then
  /usr/bin/echo "\nYou must be root to run cycle_jws_ora\n\n"
fi

# look for active users
if [ `(/usr/local/bin/lsof -i | grep httpd | grep ESTABLISHED | wc -l)` != 0 ]
 then
  /usr/bin/echo "\n\tActive web users are still accessing the server."
  /usr/bin/echo "\n\tIt is recommended that you exit this script,"
  /usr/bin/echo "\twait a few seconds and try again.\n\n"
  read answer?"Do you want to continue now? y\n\q [n] "
   ${answer:="unknown"} > /dev/null 2>&1
   if [ $answer != "y" ]
    then
    exit
   fi
fi

/usr/bin/echo "\n\tstopping the Java Web Server"
# stop jws dev interfaces...
/etc/rc0.d/K43jws.sb.interfaces-dev stop
# stop jws prod interfaces...
/etc/rc0.d/K42jws.sb.interfaces stop
# stop jws prod admin...
/etc/rc0.d/K44jws.sb.admin stop
# stop jws dev admin...
/etc/rc0.d/K45jws.sb.admin-dev stop

/usr/bin/echo "\n\tstopping the apache"
# stop prod apache...
/d0/web/prod/apache/sbin/apachectl stop
# stop dev apache...
/d0/web/dev/apache/sbin/apachectl stop

/usr/bin/echo "\n\tshutting down Oracle"
# shutdown oracle...
su - oracle -c "/export/home/oracle/bin/lsnrctl stop"
su - oracle -c /export/home/oracle/bin/sbdbshut

/usr/bin/echo "\n\tshutdown complete\n"

# wait for 15 seconds before starting everything up
/usr/bin/sleep 15

/usr/bin/echo "\n\tstarting Oracle"
# start up oracle...
su - oracle -c /export/home/oracle/bin/dbstart &
su - oracle -c "/export/home/oracle/bin/lsnrctl start"

/usr/bin/sleep 30

/usr/bin/echo "\n\tstarting apache"
# start prod apache...
/d0/web/prod/apache/sbin/apachectl start
# start dev apache...
/d0/web/dev/apache/sbin/apachectl start

/usr/bin/echo "\n\tstarting the Java Web Server"
# start jws prod interfaces...
/etc/rc3.d/S42jws.sb.interfaces start
# start jws dev interfaces...
/etc/rc3.d/S43jws.sb.interfaces-dev start
# start jws prod admin...
/etc/rc3.d/S44jws.sb.admin start
# start jws dev admin...
/etc/rc3.d/S45jws.sb.admin-dev start
/usr/bin/echo "\n\tstartup complete\n"

# This is added to bring up the weblogic server...
# /d0/startSBMCentral.csh

