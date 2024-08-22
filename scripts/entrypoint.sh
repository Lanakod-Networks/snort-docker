interface="eth0"

ip route del default
ip add sh $interface
ip route add default dev $interface
ip link set dev $interface promisc on
ethtool -K $interface gro off lro off

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf