require 'minimapper/entity/convert'
require 'active_support/core_ext'

describe Minimapper::Entity::Convert do
  it "converts strings into integers" do
    described_class.new('10').to(:integer).should == 10
    described_class.new(' 10 ').to(:integer).should == 10
  end

  it "converts datetime strings into datetimes" do
    described_class.new('2012-01-01 20:57').to(:date_time).should == DateTime.new(2012, 01, 01, 20, 57)
  end

  it "make it nil when it can't convert" do
    described_class.new(' ').to(:integer).should be_nil
    described_class.new(' ').to(:date_time).should be_nil
    described_class.new('garbage').to(:integer).should be_nil
    described_class.new('garbage').to(:date_time).should be_nil
  end

  it "returns the value as-is when it does not know how to convert it" do
    described_class.new('foobar').to(:unknown).should == 'foobar'
  end
end
