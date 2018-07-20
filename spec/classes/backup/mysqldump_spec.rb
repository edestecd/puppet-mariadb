require 'spec_helper'

describe 'mariadb::backup::mysqldump' do
  let(:pre_condition) do
    "class { '::mariadb::cluster': wsrep_cluster_peers => ['127.0.0.1', '127.0.0.2'] }"
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        let(:params) { { backupuser: 'backup', backupdir: '/tmp' } }

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
