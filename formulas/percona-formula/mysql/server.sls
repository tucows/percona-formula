# -*- coding: utf-8 -*-
# vim: ft=sls
include:
  - mysql.repo
  - mysql.config
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
    - require_in:
      - file: mysql_config

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

mysqld:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - require:
      - pkg: {{ mysql.server }}
    - watch:
      - pkg: {{ mysql.server }}
      - file: mysql_config
