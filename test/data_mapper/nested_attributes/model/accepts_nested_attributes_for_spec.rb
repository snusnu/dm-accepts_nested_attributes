require 'minitest_helper'

module DataMapper
  describe DataMapper::NestedAttributes, '#accepts_nested_attributes_for' do
    let(:options) { { } }
    let(:parent) { Source }
    let(:relationship_name) { :targets }
    let(:relationship) { parent.relationships[relationship_name] }

    subject { Source.accepts_nested_attributes_for(relationship_name, options) }

    it 'returns the receiver' do
      assert_same parent, subject
    end

    it 'stores an Acceptor in receiver.nested_attribute_acceptors[relationship_name]' do
      acceptors = subject.nested_attribute_acceptors

      assert_includes acceptors, relationship_name
      assert_kind_of NestedAttributes::Acceptor, acceptors[relationship_name]
    end

    describe 'Acceptor initialization' do
      let(:acceptor_factory) { MiniTest::Mock.new }
      let(:acceptor) { MiniTest::Mock.new }
      let(:options) { { :acceptor => acceptor_factory } }

      it 'passes the relationship as the first arg' do
        acceptor_factory.expect(:for, acceptor, [relationship, Hash])

        subject
      end

      it 'passes the options as the second arg' do
        acceptor_factory.expect(:for, acceptor, [Associations::Relationship, options])

        subject
      end
    end

  end
end
