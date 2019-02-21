require 'spec_helper'

module Puppet::Provider::TacacsServer; end
require 'puppet/provider/tacacs_server/cisco_ios'

RSpec.describe Puppet::Provider::TacacsServer::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'commands created from instance'

  context 'Read old CLI tests:' do
    load_test_data['default']['read_tests'].each do |test_name, test|
      it "Read: #{test_name}" do
        fake_device(test['device'])
        type_name = described_class.instance_method(:get).source_location.first.match(%r{provider\/(.*)\/})[1]
        new_type = Puppet::Type.type(type_name)
        dummy_context = Puppet::ResourceApi::PuppetContext
        dummy_context = dummy_context.new(new_type.type_definition.definition)
        return_non_enforced = described_class.instances_from_old_cli(test['old_cli'])
        return_enforced = PuppetX::CiscoIOS::Utility.enforce_simple_types(dummy_context, return_non_enforced)
        expect(return_enforced).to eq test['expectations_old_cli']
      end
    end
  end

  context 'Update old CLI tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'])
        if test['commands_old_cli'].size.zero?
          expect { described_class.commands_from_instance(test['instance']) }.to raise_error(%r{.*})
        else
          expect(described_class.old_cli_commands_from_instance(test['instance'])).to eq test['commands_old_cli'].first
        end
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
