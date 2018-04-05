{%- from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona')) %}

include:
  - .repo

{%- if 1 == salt['cmd.retcode']("dpkg-query -f '${Status}' -W " ~ mysql.percona_xtrabackup_version ~ " | grep -E '^(install|hold) ok installed$'", python_shell=True) %}
{{  mysql.percona_xtrabackup_version }}:
  pkg.installed
{% endif -%}
