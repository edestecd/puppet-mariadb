require 'spec_helper'

describe 'mariadb::cluster', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults' do
        let(:params) { { wsrep_cluster_peers: ['127.0.0.1', '127.0.0.2'] } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('mariadb::repo') }
        it { is_expected.to contain_class('mariadb::server::mysql') }
        it { is_expected.to contain_class('mariadb::cluster::auth') }
        it { is_expected.to contain_class('mariadb::cluster::galera_config') }
      end
    end
  end
end
