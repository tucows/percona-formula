{%- from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona')) %}

{# Find out the latest possible version by parsing Percona downloads page #}
{%- set percona_xtrabackup_latest_version = salt['cmd.run_stdout']('curl -sL https://www.percona.com/downloads/Percona-XtraBackup-LATEST/ |grep -P "<option value=\\"Percona-XtraBackup-LATEST\/Percona-XtraBackup-[0-9\.\-]*" | grep selected | sed -n "s~.*Percona-XtraBackup-\([0-9\.]*\-[0-9]\).*~\\1~p" | head -n 1', python_shell=True) %}

{# Get deb package URL of latest version #}
{%- set percona_xtrabackup_pkg_url = "https://www.percona.com/" ~ salt['cmd.run_stdout']('curl -sL -X POST -d "newBrowse=fetch-files&p=Percona-XtraBackup-LATEST/Percona-XtraBackup-' ~ percona_xtrabackup_latest_version ~ '/binary/'~ grains['os_family'] | lower ~'/' ~ grains['oscodename'] | lower ~'" https://www.percona.com/downloads-ajax |grep -oP "/downloads/Percona-XtraBackup-LATEST/Percona-XtraBackup-[^\s\\"]+' ~ mysql.tarball_os_arch | lower ~ '[^\s\\"]+percona-xtrabackup[-_][\d]+[^\s\\"]+\.deb"', python_shell=True) %}

{%- set percona_xtrabackup_version = salt['cmd.run_stdout']('echo ' ~ percona_xtrabackup_pkg_url ~ ' | grep -oP "percona-xtrabackup-([0-9]+)"', python_shell=True) %}

{%- if 1 == salt['cmd.retcode']("dpkg-query -f '${Status}' -W " ~ percona_xtrabackup_version ~ " | grep -E '^(install|hold) ok installed$'", python_shell=True) %}
{{ percona_xtrabackup_version }}:
  pkg.installed:
    - source:
      - {{ percona_xtrabackup_version }}: {{ percona_xtrabackup_pkg_url }}
{% endif -%}

