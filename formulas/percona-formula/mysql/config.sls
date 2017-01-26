# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "mysql/defaults.yaml" import rawmap with context %}
{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('mysql:lookup')) %}

mysql_config:
  file.managed:
    - name: {{ mysql.config.file }}
    - template: jinja
    - source: salt://mysql/files/my.cnf
    - user: root
    - group: root
    - mode: 644
