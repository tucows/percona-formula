# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "percona/defaults.yaml" import rawmap with context %}
{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}
{% set mysqld = mysql.config.sections.mysqld %}

{%- if mysqld.log_error is defined %}

mysql_error_log_file:
  file.managed:
    - name: {{ mysqld.log_error }}
    - owner: {{ mysqld.user }}
    - group: {{ mysqld.user }}
    - mode: 0640

{%- endif %}


{%- if mysqld.slow_query_log_file is defined %}

mysql_slow_query_log_file:
  file.managed:
    - name: {{ mysqld.slow_query_log_file }}
    - owner: {{ mysqld.user }}
    - group: {{ mysqld.user }}
    - mode: 0640

{%- endif %}

{% set logs_list = mysql.remove_default_logs|default([], True) %}
{% for log_file in logs_list %}
remove_{{ log_file }}:
  file.absent:
    - name: {{ log_file }}
{% endfor %}
