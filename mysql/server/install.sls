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
{% set defaults_extra_file = salt['pillar.get']('mysql:defaults_extra_file', mysql.defaults_extra_file) %}

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
  mysql_user:
    - present
    - name: '{{ mysql_root_user }}'
    - password: '{{ mysql_root_password }}'
    - connection_host: '{{ mysql_host }}'
    - connection_default_file: {{ defaults_extra_file }}
    - connection_charset: utf8
    - saltenv:
      - LC_ALL: "en_US.utf8"
    - require:
      - service: mysqld
      - pkg: mysql_python

root_my_cnf:
  file.managed:
    - name: /root/.my.cnf
    - template: jinja
    - source: salt://mysql/files/root_my.cnf
    - user: root
    - group: root
    - mode: 600
    - context:
       mysql_root_user: '{{ mysql_root_user }}'
       mysql_root_password: '{{ mysql_root_password }}'
    - require:
      - mysql_user: mysql_root_password

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
      - mysql_user: mysql_root_password
      {%- endif %}
{% endfor %}

mysql_tzinfo_to_sql:
  cmd.run:
    - name: mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --defaults-extra-file=/root/.my.cnf mysql
    - unless: test $(mysql --defaults-extra-file=/root/.my.cnf mysql -sN --execute="select count(*) from time_zone;") -gt 0
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
