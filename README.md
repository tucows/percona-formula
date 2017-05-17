
# percona-formula [![Build Status](https://travis-ci.org/Perceptyx/percona-formula.png?branch=master)](https://travis-ci.org/Perceptyx/percona-formula)


A saltstack formula that configures Percona Server.


## Available states

- [`client`](#Client)

- [`server`](#Server)

### Client

- Installs Percona Server client package.

### Server

- Installs Percona Server Server package
- Configure root password
- Remove MySQL users without host or without username
- Import MySQL timezone information
- Enables and starts MySQL service

 
