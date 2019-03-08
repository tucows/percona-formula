{% from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}

include:
  - percona.repo

percona-xtrabackup:
  pkg.installed:
    - name: {{ mysql.xtrabackup_pkg }}
