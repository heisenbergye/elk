ELK stack to be configured as an Juniper SRX log analizer

At first an SRX has to be configured the following way:
1. structured control-plane logs

    set system syslog host 1.1.2.10 any any
    set system syslog host 1.1.2.10 structured-data brief

2. structured data-plane logs

    set security log mode stream
    set security log format sd-syslog
    set security log source-address 1.2.3.4
    set security log stream streamlog format sd-syslog
    set security log stream streamlog category all
    set security log stream streamlog host 1.1.2.10
    set security log stream streamlog host port 514

3. application identification and apptrack feature (optional)

    set security zones security-zone WiFi application-tracking


So the SRX has been configured and is sending logs to a syslog server (it can be easily verified by running tcpdump -A udp and port 514)
Now we can build and run the docker container:  

user@host> git clone URL
user@host> build . -t my_elk
user@host> sudo docker run -dit -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 514:1514/udp -p 9996:9996/udp -v elk-data:/var/lib/elasticsearch --name elk my_elk

* port 514/udp could be replaced with any port with number greater 1024. no sudo in that case
** 9996/udp reserved for the netflow logstash module. at the time syslog and netflow can't be run simultaneously 

