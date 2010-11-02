require 'spec_helper'

describe "DataMapper::Model#assign_nested_attributes_for" do

  fixtures = <<-RUBY

    class ::Branch
      include DataMapper::Resource
      property :id, Serial
      has 1, :shop
      has n, :items
      has n, :bookings, :through => :items

      accepts_nested_attributes_for :shop
      accepts_nested_attributes_for :items
      accepts_nested_attributes_for :bookings
    end

    class ::Shop
      include DataMapper::Resource
      property :id,        Serial
      belongs_to :branch
    end

    class ::Item
      include DataMapper::Resource
      property :id,        Serial
      belongs_to :branch
      has n, :bookings
    end

    class ::Booking
      include DataMapper::Resource
      property :id,      Serial
      belongs_to :item
    end

  RUBY

  before(:all) do
    eval fixtures
    DataMapper.auto_migrate!
  end

  before(:each) do
    Object.send(:remove_const, 'Branch')  if Object.const_defined?('Branch')
    Object.send(:remove_const, 'Shop')    if Object.const_defined?('Shop')
    Object.send(:remove_const, 'Item')    if Object.const_defined?('Item')
    Object.send(:remove_const, 'Booking') if Object.const_defined?('Booking')

    eval fixtures # neither class_eval nor instance_eval work here
  end


  describe "resource" do
    it "should raise unless called with a Hash" do
      lambda { Branch.new.shop_attributes = [] }.should raise_error(ArgumentError)
      lambda { Branch.new.shop_attributes = "" }.should raise_error(ArgumentError)
    end

    it "should not raise when called with a Hash" do
      lambda { Branch.new.shop_attributes = {} }.should_not raise_error(ArgumentError)
    end
  end

  describe "collection" do
    it "should not raise when called with a Hash of Hashes" do
      lambda { Branch.new.items_attributes = {:a => {}} }.should_not raise_error(ArgumentError)
    end

    it "should not raise when called with an Array of Hashes" do
      lambda { Branch.new.items_attributes = [{}] }.should_not raise_error(ArgumentError)
    end

    it "should raise when called with a param that is not a Hash or Array" do
      lambda { Branch.new.items_attributes = "" }.should raise_error(ArgumentError)
    end

    it "should raise when called with a Hash that includes not only Hashes" do
      lambda { Branch.new.items_attributes = {:a => "", :b => {}} }.should raise_error(ArgumentError)
    end

    it "should raise when called with an Array that includes not only Hashes" do
      lambda { Branch.new.items_attributes = ["", {}] }.should raise_error(ArgumentError)
    end
  end

  describe "collection with :through" do
    it "should raise unless called with a Hash or Array" do
      lambda { Branch.new.bookings_attributes = "" }.should raise_error(ArgumentError)
    end

    it "should not raise when called with a Hash" do
      lambda { Branch.new.bookings_attributes = {} }.should_not raise_error(ArgumentError)
    end

    it "should not raise when called with an Array" do
      lambda { Branch.new.bookings_attributes = [] }.should_not raise_error(ArgumentError)
    end
  end
end
