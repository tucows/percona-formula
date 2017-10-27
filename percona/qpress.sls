{%- from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona')) %}
{# qpress seems to always be version 11-1 #}
{%- set qpress_pkg = 'https://repo.percona.com/apt/pool/main/q/qpress/qpress_11-1.' ~ grains['oscodename'] | lower ~ '_' ~ mysql.os_arch ~ '.deb' %}

{%- if 1 == salt['cmd.retcode']("dpkg-query -f '${Status}' -W qpress | grep -E '^(install|hold) ok installed$'", python_shell=True) %}
qpress:
  pkg.installed:
    - sources:
      - qpress: {{ qpress_pkg }}
{% endif -%}
