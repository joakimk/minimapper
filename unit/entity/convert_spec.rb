require 'minimapper/entity/convert'
require 'active_support/core_ext'

describe Minimapper::Entity::Convert do
  describe ":integer" do
    it "allows integers" do
      described_class.new(10).to(:integer).should == 10
    end

    it "converts strings into integers" do
      described_class.new('10').to(:integer).should == 10
      described_class.new(' 10 ').to(:integer).should == 10
    end

    it "makes it nil when it can't convert" do
      described_class.new(' ').to(:integer).should be_nil
      described_class.new('garbage').to(:integer).should be_nil
    end
  end

  describe ":date_time" do
    it "allows DateTimes" do
      described_class.new(DateTime.new(2013, 6, 1)).to(:date_time).should == DateTime.new(2013, 6, 1)
    end

    it "converts datetime strings into datetimes" do
      described_class.new('2012-01-01 20:57').to(:date_time).should == DateTime.new(2012, 01, 01, 20, 57)
    end

    it "makes it nil when it can't convert" do
      described_class.new(' ').to(:date_time).should be_nil
      described_class.new('garbage').to(:date_time).should be_nil
    end
  end

  it "returns the value as-is when the type isn't specified" do
    described_class.new('foobar').to(nil).should == 'foobar'
  end

  it "raises when the type isn't known" do
    lambda { described_class.new('foobar').to(:unknown) }.should raise_error(/Unknown attribute type/)
  end

  it "does not make false nil" do
    described_class.new(false).to(:whatever).should eq(false)
  end
end
