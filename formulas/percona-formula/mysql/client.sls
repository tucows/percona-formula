# -*- coding: utf-8 -*-
# vim: ft=sls
include:
  - mysql.repo

{% from "mysql/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('mysql:lookup')) %}

mysql-pkg:
  pkg.installed:
    - name: {{ mysql.client }}
