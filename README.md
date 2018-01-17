**ELK stack to be configured as an Juniper SRX log analizer**

At first an SRX has to be configured the following way:
1. structured control-plane logs
```
    set system syslog host 1.1.2.10 any any
    set system syslog host 1.1.2.10 structured-data brief
```
2. structured data-plane logs
```
    set security log mode stream
    set security log format sd-syslog
    set security log source-address 1.2.3.4
    set security log stream streamlog format sd-syslog
    set security log stream streamlog category all
    set security log stream streamlog host 1.1.2.10
    set security log stream streamlog host port 514
```
3. RT_FLOW logs 
```
set security policies from-zone WiFi to-zone untrust policy Wifi-to-Inet then log session-init
set security policies from-zone WiFi to-zone untrust policy Wifi-to-Inet then log session-close
```
4. (optional) instead of RT_FLOW logs you can use application identification feature as well.
This feature is based on IDS sinatures that require an APPSEC license.
although you can use a trial one by issuing the followings commands:
```
   request system license update trial   
   request security idp security-package download
   request security idp security-package install
```
all the commands above require some time to have completed

then you have IDS signatures downloaded and installed you can use apptrack feature by configuring it the following way
```
    set security zones security-zone WiFi application-tracking
```

So the SRX has been configured and is sending logs to a syslog server (it can be easily verified by running tcpdump -A udp and port 514)
Now we can build and run the docker container:  
```
user@host> git clone URL
user@host> build . -f Dockerfile.elk -t my_elk
user@host> sudo docker run -it -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 514:1514/udp -p 9996:9996/udp -v elk-data:/var/lib/elasticsearch --name elk my_elk
```
_port 514/udp could be replaced with any port with number greater 1024. no sudo in that case
9996/udp reserved for the netflow logstash module. at the time syslog and netflow can't be run simultaneously_


**additional ELK instance to add netflow analizer to a stack**
I couldn't run logstash with a syslog input filter and the logstash built-in netflow module simultaneously
Logstash's developers insist on running separate logstash instances if you need modules and pipelined configuration
So lets create another docker container with no pipeline configuration and run it
```
user@host> build . -f Dockerfile.elk_netflow -t my_elk
user@host> docker run -it --rm -p 9996:9996/udp -v elk-data2:/var/lib/elasticsearch -e KIBANA_START=0 --link elk:elk --name elk_netflow elk_netflow
```
