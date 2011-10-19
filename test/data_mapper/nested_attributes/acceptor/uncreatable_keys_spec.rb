require 'minitest_helper'

describe DataMapper::NestedAttributes::Acceptor, '#uncreatable_keys' do
  it "includes delete marker with a simple primary key" do
    acceptor = ::Person.nested_attribute_acceptors[:memberships]

    assert_equal [:_delete], acceptor.uncreatable_keys(::Person.new)
  end

  it "includes delete marker with a composite primary key" do
    acceptor = ::Membership.nested_attribute_acceptors[:person]

    assert_equal [:_delete], acceptor.uncreatable_keys(::Membership.new)
  end
end
