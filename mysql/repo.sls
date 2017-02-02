# -*- coding: utf-8 -*-
# vim: ft=sls
{% set ubuntu_release = salt['grains.get']('oscodename', None) %}

percona-release:
  pkg.installed:
    - sources:
      - percona-release: https://repo.percona.com/apt/percona-release_0.1-4.{{ ubuntu_release }}_all.deb
    - allow_updates: True
    - skip_suggestions: True
    - refresh: True
