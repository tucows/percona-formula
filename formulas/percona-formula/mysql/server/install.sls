# -*- coding: utf-8 -*-
# vim: ft=sls
include:
  - mysql.repo
  - mysql.python

{% from "mysql/defaults.yaml" import rawmap with context %}

{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('mysql:lookup')) %}
{% set mysql_root_user = salt['pillar.get']('mysql:server:root_user', 'root') %}
{% set mysql_root_password = salt['pillar.get']('mysql:server:root_password', salt['random.get_str'](32)) %}
{% set mysql_host = salt['pillar.get']('mysql:server:host', 'localhost') %}

mysql_debconf_utils:
  pkg.installed:
    - name: {{ mysql.debconf_utils }}

mysql_debconf:
  debconf.set:
    - name: {{ mysql.server }}
    - data:
        '{{ mysql.server_short }}/root_password': {'type': 'password', 'value': '{{ mysql_root_password }}'}
        '{{ mysql.server_short }}/root_password_again': {'type': 'password', 'value': '{{ mysql_root_password }}'}
        '{{ mysql.server }}/start_on_boot': {'type': 'boolean', 'value': 'true'}
    - require_in:
      - pkg: {{ mysql.server }}
    - require:
      - pkg: {{ mysql.debconf_utils }}

percona-server-pkg:
  pkg.installed:
    - name: {{ mysql.server }}
    - require:
      - debconf: mysql_debconf

mysql_root_password:
  cmd.run:
    - name: mysqladmin --user {{ mysql_root_user }} password '{{ mysql_root_password|replace("'", "'\"'\"'") }}'
    - unless: mysql --user {{ mysql_root_user }} --password='{{ mysql_root_password|replace("'", "'\"'\"'") }}' --execute="SELECT 1;"
    - require:
      - service: mysqld

root_my_cnf:
  file.managed:
    - name: /root/.my.cnf
    - template: jinja
    - source: salt://mysql/files/root_my.cnf
    - user: root
    - group: root
    - mode: 600
    {%- if mysql_root_user and mysql_root_password %}
    - context:
       mysql_root_user: {{ mysql_root_user }}
       mysql_root_password: {{ mysql_root_password|replace("'", "'\"'\"'") }}
    - require:
      - cmd: mysql_root_password
    {%- endif %}

{% for host in ['localhost', 'localhost.localdomain', salt['grains.get']('fqdn')] %}
mysql_delete_anonymous_user_{{ host }}:
  mysql_user:
    - absent
    - host: {{ host or "''" }}
    - name: ''
    - connection_host: '{{ mysql_host }}'
    - connection_user: '{{ mysql_root_user }}'
    {% if mysql_root_password %}
    - connection_pass: '{{ mysql_root_password }}'
    {% endif %}
    - connection_charset: utf8
    - require:
      - service: mysqld
      - pkg: mysql_python
      {%- if mysql_root_user and mysql_root_password %}
      - cmd: mysql_root_password
      {%- endif %}
{% endfor %}

mysql_tzinfo_to_sql:
  cmd.run:
    - name: mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --defaults-extra-file=/root/.my.cnf mysql
    - unless: mysql --defaults-extra-file=/root/.my.cnf mysql --execute="SHOW TABLES;" | grep -q 'time_zone'
    - require:
      - service: mysqld
      - file: root_my_cnf

mysqld:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - require:
      - pkg: {{ mysql.server }}
    - watch:
      - pkg: {{ mysql.server }}

# Require this to apply configuration file WITH zone settings
mysqld_config_changed:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - restart: True
    - require:
      - service: mysqld
    - watch:
      - file: mysql_config
