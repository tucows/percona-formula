# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "percona/defaults.yaml" import rawmap with context %}
{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}

mysql_config:
  file.managed:
    - name: {{ mysql.config.file }}
    - template: jinja
    - source: salt://percona/files/my.cnf
    - user: root
    - group: root
    - mode: 644
  module.run:
{% if grains['saltversion'] < '2017.7.0' %}
    - name: service.restart
    - m_name: {{ mysql.service }}
{% else %}
    - service.restart:
      - name: {{ mysql.service }}
{% endif %}
    - onchanges:
      - file: mysql_config

{# If you use old 5.6 versions with a big database service start will report
failure on start due to hardcoded timeout #}
{# https://bugs.launchpad.net/percona-server/+bug/1434022 #}
{%- if mysql.major_version|string == '5.6' %}
mysql_init_script:
  file.managed:
    - name: /etc/init.d/mysql
    - source: https://raw.githubusercontent.com/percona/percona-server/5.6/build-ps/debian/percona-server-server-5.6.mysql.init
    - skip_verify: True
    - user: root
    - group: root
    - mode: 0755
    - watch_in:
      - file: mysql_config
{% endif %}
