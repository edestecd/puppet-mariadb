require 'spec_helper'

describe 'mariadb::client', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('mariadb::repo') }
        it { is_expected.to contain_class('mariadb::client::mysql') }
        it { is_expected.to contain_class('mysql::client') }
        it { is_expected.to contain_class('mysql::bindings') }
        it { is_expected.to contain_class('mariadb::client::config') }
      end
    end
  end
end
