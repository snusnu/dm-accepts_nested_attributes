require 'minitest_helper'

describe DataMapper::NestedAttributes::Acceptor, '#unupdateable_keys' do
  it "includes simple primary key and delete marker" do
    acceptor = Person.nested_attribute_acceptors[:memberships]

    assert_equal [:id, :_delete], acceptor.unupdatable_keys(Person.new)
  end

  it "includes primary keys and delete marker" do
    acceptor = Membership.nested_attribute_acceptors[:person]
    expected = [:person_id, :project_id, :_delete]

    assert_equal expected, acceptor.unupdatable_keys(Membership.new)
  end
end
