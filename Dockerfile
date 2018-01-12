FROM sebp/elk

# overwrite existing file
ADD 10-syslog.conf /etc/logstash/conf.d/10-syslog.conf
ADD 30-output.conf /etc/logstash/conf.d/30-output.conf
#ADD logstash.yml ${LOGSTASH_HOME}/config/logstash.yml

# add new file
ADD 12-syslog-input.conf /etc/logstash/conf.d/12-syslog-input.conf
#ADD debug.config /etc/logstash/debug.config

WORKDIR ${LOGSTASH_HOME}

ENV http_proxy="http://10.2.1.96:8118"
ENV https_proxy=$http_proxy
ENV JRUBY_OPTS="-J-Dhttp.proxyHost=10.2.1.96 -J-Dhttp.proxyPort=8118"

RUN gosu logstash bin/logstash-plugin install logstash-input-syslog
RUN gosu logstash bin/logstash-plugin install logstash-filter-geoip
