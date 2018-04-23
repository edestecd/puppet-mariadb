require 'spec_helper'

describe 'mariadb::repo', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        if facts[:osfamily] == 'RedHat'
          it { is_expected.to contain_class('mariadb::repo::yum') }
          it { is_expected.not_to contain_class('mariadb::repo::apt') }
        elsif facts[:osfamily] == 'Debian'
          it { is_expected.not_to contain_class('mariadb::repo::yum') }
          it { is_expected.to contain_class('mariadb::repo::apt') }
        end
      end
    end
  end
end
