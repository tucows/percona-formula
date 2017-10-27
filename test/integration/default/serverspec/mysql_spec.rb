require 'serverspec'
require 'spec_helper'

# Required by serverspec
set :backend, :exec

mysql = YAML.load_file('/tmp/mysql.config')
mysql_query = "mysql --defaults-extra-file=/root/.my.cnf mysql -sN -e"

describe "MySQL" do
  # ===== MySQL critical tests ======
  it "server package is installed" do
    expect(package("#{mysql['pkg_prefix']}-server-#{mysql['major_version']}")).to be_installed
  end

  it "client package is installed" do
    expect(package("#{mysql['pkg_prefix']}-client-#{mysql['major_version']}")).to be_installed
  end

  it "qpress package is installed" do
    expect(package("qpress")).to be_installed
  end

  if mysql['version'] then
    if mysql['major_version'] == '5.6' then
      version_suffix = ''
    else
      version_suffix = "-#{mysql['major_version']}"
    end

    it "server package version is #{mysql['version']}-1.#{$codename}" do
      expect(package("#{mysql['pkg_prefix']}-server#{version_suffix}")).to be_installed.with_version("#{mysql['version']}-1.#{$codename}")
    end

    it "client package version is #{mysql['version']}-1.#{$codename}" do
      expect(package("#{mysql['pkg_prefix']}-client#{version_suffix}")).to be_installed.with_version("#{mysql['version']}-1.#{$codename}")
    end
  end

  it "is listening on port #{mysql['config']['sections']['mysqld']['port'] || 3306}" do
    expect(port(mysql['config']['sections']['mysqld']['port'] || 3306)).to be_listening
  end

  it "service is running" do
    expect(service(mysql['service'])).to be_running
  end

  it "is enabled to start on boot" do
    expect(service(mysql['service'])).to be_enabled
  end

  # ===== MySQL critical settings ======
  it "timezone is #{mysql['config']['sections']['mysqld']['default_time_zone']}" do
    expect(command("#{mysql_query} \"show variables like 'time_zone';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['default_time_zone']}/)
  end

  # ===== MySQL Log files ======
  it "log_error is configured to #{mysql['config']['sections']['mysqld']['log_error']}" do
    expect(command("#{mysql_query} \"show variables like 'log_error';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['log_error']}/)
  end

  it "#{mysql['config']['sections']['mysqld']['log_error']} is a file" do
    expect(file("#{mysql['config']['sections']['mysqld']['log_error']}")).to be_file
  end

  it "#{mysql['config']['sections']['mysqld']['log_error']} is a owned by #{mysql['config']['sections']['mysqld']['user']}" do
    expect(file("#{mysql['config']['sections']['mysqld']['log_error']}")).to be_owned_by mysql['config']['sections']['mysqld']['user']
  end

  it "slow_query_log_file is configured to #{mysql['config']['sections']['mysqld']['slow_query_log_file']}" do
    expect(command("#{mysql_query} \"show variables like 'slow_query_log_file';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['slow_query_log_file']}/)
  end

  it "#{mysql['config']['sections']['mysqld']['slow_query_log_file']} is a file" do
    expect(file("#{mysql['config']['sections']['mysqld']['slow_query_log_file']}")).to be_file
  end

  it "#{mysql['config']['sections']['mysqld']['slow_query_log_file']} is a owned by #{mysql['config']['sections']['mysqld']['user']}" do
    expect(file("#{mysql['config']['sections']['mysqld']['slow_query_log_file']}")).to be_owned_by mysql['config']['sections']['mysqld']['user']
  end

  # ===== MySQL other settings ======
  it "datadir is #{mysql['config']['sections']['mysqld']['datadir']}" do
    expect(command("#{mysql_query} \"show variables like 'datadir';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['datadir']}/)
  end

  it "binlog_format is #{mysql['config']['sections']['mysqld']['binlog_format']}" do
    expect(command("#{mysql_query} \"show variables like 'binlog_format';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['binlog_format']}/)
  end

  it "max_connections is #{mysql['config']['sections']['mysqld']['max_connections']}" do
    expect(command("#{mysql_query} \"show variables like 'max_connections';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['max_connections']}/)
  end

  it "innodb_file_format is #{mysql['config']['sections']['mysqld']['innodb_file_format']}" do
    expect(command("#{mysql_query} \"show variables like 'innodb_file_format';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['innodb_file_format']}/)
  end

  it "character_set_server is #{mysql['config']['sections']['mysqld']['character_set_server']}" do
    expect(command("#{mysql_query} \"show variables like 'character_set_server';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['character_set_server']}/)
  end

  it "default_storage_engine is #{mysql['config']['sections']['mysqld']['default_storage_engine']}" do
    expect(command("#{mysql_query} \"show variables like 'default_storage_engine';\"").stdout).to match(/#{mysql['config']['sections']['mysqld']['default_storage_engine']}/)
  end

end
