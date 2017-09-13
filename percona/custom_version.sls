{% from "percona/defaults.yaml" import rawmap with context %}

include:
  - percona.repo

{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}

{# We want to install a custom version and it's not in repository #}
{%- if (mysql.version is defined and mysql.version != '') and salt['cmd.retcode']('apt-cache madison ' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ ' | grep -qP \'(^|\s)\K' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ '(?=\s|$)\' | grep -qP \'(^|\s)\K' ~ mysql.version ~ '-1(?=\s|$)\'', python_shell=True) == 1 %}
percona-custom-version:
  pkg.latest:
    - pkgs:
      - zlib1g-dev
      - libdbi-perl
      - libdbd-mysql-perl
      - libaio1
      - libwrap0
      - psmisc
      - curl

{%- set percona_tarball_url = salt['cmd.run_stdout']('curl -sL ' ~ mysql.percona_url ~ ' | grep -oP "\/downloads[^\s>]+' ~ mysql.tarball_suffix ~ '\.tar" | sed -e "s/^/https\:\/\/www.percona.com/"', python_shell=True) %}
  archive.extracted:
    - name: /tmp/percona
    - source: {{ percona_tarball_url }}
    - enforce_toplevel: False
    - skip_verify: True
    - trim_output: True
    - keep: True
    - if_missing: /tmp/percona
    - require:
      - pkg: percona-custom-version
    - require_in:
      - pkg: percona-server-pkg
      - pkg: mysql-pkg
{% endif %}
