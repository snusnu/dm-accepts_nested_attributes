require 'minitest_helper'

module DataMapper
  describe NestedAttributes, '#accepts_nested_attributes_for' do
    let(:relationship) { Source.relationships[:targets] }
    let(:options) { {} }

    subject { NestedAttributes::Acceptor.new(relationship, options) }

    it 'provides access to the first arg as #relationship' do
      assert_same relationship, subject.relationship
    end

    it 'defaults acceptor#allow_destroy? to false' do
      refute_predicate subject, :allow_destroy?
    end

    it 'defaults acceptor#reject_if to nil' do
      assert_nil subject.reject_if
    end

    describe 'with :allow_destroy => true' do
      let(:options) { { :allow_destroy => true } }

      it 'captures the :allow_destroy option as #allow_destroy?' do
        assert_predicate subject, :allow_destroy?
      end
    end

    describe 'with :guard_factory => true' do
      let(:options) { { :allow_destroy => true } }

      it 'captures the :allow_destroy option as #allow_destroy?' do
        assert_predicate subject, :allow_destroy?
      end
    end

  end
end
