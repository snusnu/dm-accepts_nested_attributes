require 'minitest_helper'

module DataMapper
  describe DataMapper::NestedAttributes, '#accepts_nested_attributes_for' do
    let(:options) { { :allow_destroy => true } }
    let(:parent) { Source}
    let(:relationship_name) { :targets }

    subject { Source.accepts_nested_attributes_for(relationship_name, options) }

    it 'returns the receiver' do
      assert_same parent, subject
    end

    it 'stores an Acceptor in receiver.nested_attribute_acceptors[relationship_name]' do
      acceptors = subject.nested_attribute_acceptors

      assert_includes acceptors, relationship_name
      assert_kind_of NestedAttributes::Acceptor, acceptors[relationship_name]
    end

    it 'initializes the stored Acceptor with the expected relationship' do
      acceptor = subject.nested_attribute_acceptors[relationship_name]
      expected_relationship = subject.relationships[relationship_name]

      assert_same expected_relationship, acceptor.relationship
    end

    it 'initializes the stored Acceptor with the expected allow_destroy value' do
      acceptor = subject.nested_attribute_acceptors[relationship_name]

      assert_same true, acceptor.allow_destroy?
    end

  end
end
