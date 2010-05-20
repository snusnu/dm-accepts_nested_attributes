require 'dm-core/spec/setup'
require 'dm-core/spec/lib/pending_helpers'

require 'dm-accepts_nested_attributes'

require 'shared/many_to_many_spec'
require 'shared/many_to_one_spec'
require 'shared/one_to_many_spec'
require 'shared/one_to_one_spec'

DataMapper::Spec.setup

HAS_M2M_SUPPORT = !%w[in_memory yaml].include?(DataMapper::Spec.adapter_name)

module ConstraintSupport

  def constraint(type)
    if DataMapper.const_defined?('Constraints')
      { :constraint => type }
    else
      {}
    end
  end

end

Spec::Runner.configure do |config|

  config.include(DataMapper::Spec::PendingHelpers)

  config.after(:suite) do
    if DataMapper.respond_to?(:auto_migrate_down!, true)
      DataMapper.send(:auto_migrate_down!, DataMapper::Spec.adapter.name)
    end
  end

end
