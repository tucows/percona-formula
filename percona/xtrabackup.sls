{%- from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona')) %}
{%- set percona_xtrabackup_url = 'https://www.percona.com/downloads/XtraBackup/LATEST/binary/' ~ grains['os_family'] | lower ~ '/' ~ grains['oscodename'] ~ '/' ~ mysql.tarball_os_arch ~ '/' %}
{%- set percona_xtrabackup_pkg_url = salt['cmd.run_stdout']('curl -sL ' ~ percona_xtrabackup_url ~ ' | grep -oP "\/downloads[^\s>]+percona-xtrabackup-([0-9])+[^\s]+.' ~ grains['oscodename'] ~ '_' ~ mysql.os_arch ~ '\.deb" | tail -1 | sed -e "s/^/https\:\/\/www.percona.com/"', python_shell=True) %}
{%- set percona_xtrabackup_version = salt['cmd.run_stdout']('echo ' ~ percona_xtrabackup_pkg_url ~ ' | grep -oP "percona-xtrabackup-([0-9]+)"', python_shell=True) %}

{{ percona_xtrabackup_version }}:
  pkg.installed:
    - sources:
      - {{ percona_xtrabackup_version }}: {{ percona_xtrabackup_pkg_url }}
