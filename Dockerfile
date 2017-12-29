FROM sebp/elk

# overwrite existing file
#ADD /path/to/your-30-output.conf /etc/logstash/conf.d/30-output.conf
ADD 10-syslog.conf /etc/logstash/conf.d/10-syslog.conf
ADD 30-output.conf /etc/logstash/conf.d/30-output.conf

# add new file
#ADD /path/to/new-12-some-filter.conf /etc/logstash/conf.d/12-some-filter.conf
ADD 12-syslog-input.conf /etc/logstash/conf.d/12-syslog-input.conf
#ADD debug.config /etc/logstash/debug.config

WORKDIR ${LOGSTASH_HOME}

ENV http_proxy="http://10.2.1.96:8118"
ENV https_proxy=$http_proxy
ENV JRUBY_OPTS="-J-Dhttp.proxyHost=10.2.1.96 -J-Dhttp.proxyPort=8118"

RUN gosu logstash bin/logstash-plugin install logstash-input-syslog

