ip route del default
#ip route add default via 192.168.88.108
ip route add default dev eth0


/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf