{%- from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona')) %}
{%- set percona_cacti_plugin_url = 'https://www.percona.com/downloads/percona-monitoring-plugins/LATEST/binary/' ~ grains['os_family'] | lower ~ '/' ~ grains['oscodename'] ~ '/' ~ mysql.tarball_os_arch ~ '/' %}
{%- set percona_cacti_plugin_pkg_url = salt['cmd.run_stdout']('curl -sL ' ~ percona_cacti_plugin_url ~ ' | grep -oP "\/downloads[^\s>]+\.deb" | grep -i cacti | tail -1 | sed -e "s/^/https\:\/\/www.percona.com/"', python_shell=True) %}

{%- if 1 == salt['cmd.retcode']("dpkg-query -f '${Status}' -W percona-cacti-templates | grep -E '^(install|hold) ok installed$'", python_shell=True) %}
percona-cacti-templates:
  pkg.installed:
    - sources:
      - percona-cacti-templates: {{ percona_cacti_plugin_pkg_url }}
{% endif %}
