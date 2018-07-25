require 'spec_helper'

describe 'mariadb::backup::mariabackup' do
  let(:pre_condition) do
    "class { '::mariadb::cluster': wsrep_cluster_peers => ['127.0.0.1', '127.0.0.2'] }"
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:default_params) do
        { 'backupuser'         => 'backup',
          'backuppassword'     => 'testpass',
          'backupdir'          => '/tmp',
          'backupdirowner'     => 'mysql',
          'backupdirgroup'     => 'mysql',
          'incremental'        => true }
      end

      context 'standard conditions' do
        let(:params) { default_params }

        it {
          is_expected.to contain_mysql_user('backup@localhost').with(
            require: 'Class[Mysql::Server::Root_password]',
          )
        }

        context 'with logging_enabled set to true' do
          let(:params) do
            { logging_enabled: true,
              log_path: '/tmp',
              log_file: 'test.log' }.merge(default_params)
          end

          it {
            is_expected.to contain_cron('mariabackup').with(
              command: '/usr/local/sbin/mariabackup.sh >>/tmp/test.log 2>&1',
              ensure: 'present',
            )
          }
        end

        context 'with postscript' do
          let(:params) do
            default_params.merge(
              postscript: [
                'if [ ${exitcode} != 0 ]; then',
                ' echo "MariaDB backup failed on test.server.com" | mail -s "MariaDB backup failed!" email-account@test.org',
                'fi',
              ],
            )
          end

          it 'is add postscript' do
            is_expected.to contain_file('mariabackup.sh').with_content(
              %r{if [ ${exitcode} != 0 ]; then\n\n echo "MariaDB backup failed on test.server.com" | mail -s "MariaDB backup failed!" email-account@test.org\n\nfi},
            )
          end
        end
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
