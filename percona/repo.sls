# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "percona/defaults.yaml" import rawmap with context %}
{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona')) %}

{%- if mysql.version is defined %}
{#
Versions are like: 5.6.36-82.0-1.precise
We expect them in format: 5.6.36-82.0-1 and we add the release info
#}

{%- set libperconaserverclient_version = salt['cmd.run_stdout']('curl -sL ' ~ mysql.percona_url ~ ' | grep -oP "\/downloads[^\s>]+libperconaserverclient([0-9|\.]*)_[^\s>]+\.' ~ grains['oscodename'] | lower ~ '_' ~ mysql.os_arch ~ '\.deb" | sed -n "s/\/downloads\(.*\)libperconaserverclient\([0-9|\.]*\)\_\(.*\)/\\2/p"', python_shell=True) %}

/etc/apt/preferences.d/percona:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - contents: |
        Package: percona-server*
        Pin: version {{ mysql.version }}-1.{{ grains['oscodename'] }}
        Pin-Priority: 1001
    - require_in:
      - pkg: percona-server-pkg
      - pkg: mysql-pkg

/etc/apt/preferences.d/libpercona:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - contents: |
        Package: libperconaserverclient{{ libperconaserverclient_version }}
        Pin: version {{ mysql.version }}-1.{{ grains['oscodename'] }}
        Pin-Priority: 1001

        Package: libperconaserverclient{{ libperconaserverclient_version }}-dev
        Pin: version {{ mysql.version }}-1.{{ grains['oscodename'] }}
        Pin-Priority: 1001
    - require_in:
      - pkg: percona-server-pkg
      - pkg: mysql-pkg

{% endif %}

{%- if grains['os_family'] == 'Debian' %}
percona-repository:
  pkgrepo.managed:
    - humanname: Percona Repository
    - name: deb http://repo.percona.com/apt {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/percona.list
    - keyid: 8507EFA5
    - keyserver: keyserver.ubuntu.com
    - gpgcheck: 1
    - clean_file: true
    - require_in:
      - pkg: percona-server-pkg
      - pkg: mysql-pkg

percona-repository-src:
  pkgrepo.managed:
    - humanname: Percona Repository SRC
    - name: deb-src http://repo.percona.com/apt {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/percona-src.list
    - keyid: 8507EFA5
    - keyserver: keyserver.ubuntu.com
    - gpgcheck: 1
    - clean_file: true
    - require_in:
      - pkg: percona-server-pkg
      - pkg: mysql-pkg
{%- elif grains['os_family'] == 'RedHat' %}
percona-repository:
    - humanname: Percona Repository
    - baseurl: http://repo.percona.com/centos/$releasever/os/$basearch
    - enabled: true
    - gpgcheck: 1
    - gpgkey: https://www.percona.com/downloads/RPM-GPG-KEY-percona
    - require_in:
      - pkg: percona-server-pkg
      - pkg: mysql-pkg
{% endif %}
