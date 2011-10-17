require 'minitest_helper'

module DataMapper
  describe NestedAttributes, '#accepts_nested_attributes_for' do
    let(:relationship) { Source.relationships[:targets] }
    let(:options) { { :allow_destroy => true } }

    subject { NestedAttributes::Acceptor.new(relationship, options) }

    it 'provides access to the first arg as #relationship' do
      assert_same relationship, subject.relationship
    end

    it 'captures the :allow_destroy option as #allow_destroy?' do
      assert_predicate subject, :allow_destroy?
    end

  end
end
