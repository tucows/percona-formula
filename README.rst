
# percona-formula [![Build Status](https://travis-ci.org/Perceptyx/percona-formula.png?branch=master)](https://travis-ci.org/Perceptyx/percona-formula)

================

A saltstack formula that configures Percona Server.


## Available states

``client``
------------

Installs Percona Server client package.

``server``
------------

- Installs Percona Server Server package
- Configure root password
- Remove MySQL users without host or without username
- Import MySQL timezone information
- Enables and starts MySQL service
