# -*- coding: utf-8 -*-
# vim: ft=sls

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
      - percona-server-pkg
      - mysql-pkg

percona-repository-src:
  pkgrepo.managed:
    - humanname: Percona Repository
    - name: deb-src http://repo.percona.com/apt {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/percona-src.list
    - keyid: 8507EFA5
    - keyserver: keyserver.ubuntu.com
    - gpgcheck: 1
    - clean_file: true
{%- elif grains['os_family'] == 'RedHat' %}
percona-repository:
    - humanname: Percona Repository
    - baseurl: http://repo.percona.com/centos/$releasever/os/$basearch
    - enabled: true
    - gpgcheck: 1
    - gpgkey: https://www.percona.com/downloads/RPM-GPG-KEY-percona
    - require_in:
      - percona-server-pkg
      - mysql-pkg
{% endif %}
