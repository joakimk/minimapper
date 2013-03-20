require 'minimapper/repository'
require 'minimapper/mapper/memory'

module Test
  class ProjectMapper < Minimapper::Mapper::Memory
  end
end

describe Minimapper::Repository, "self.build" do
  it "builds a repository" do
    repository = described_class.build(:projects => Test::ProjectMapper.new)
    repository.should be_instance_of(Minimapper::Repository)
    repository.projects.should be_instance_of(Test::ProjectMapper)
  end

  it "memoizes the mappers" do
    repository = described_class.build(:projects => Test::ProjectMapper.new)
    repository.projects.object_id.should == repository.projects.object_id
  end

  it "adds a reference to the repository" do
    mapper = Test::ProjectMapper.new
    repository = described_class.build(:projects => mapper)
    mapper.repository.should == repository
  end

  it "does not leak between instances" do
    mapper1 = mock.as_null_object
    mapper2 = mock.as_null_object
    repository1 = described_class.build(:projects => mapper1)
    repository2 = described_class.build(:projects => mapper2)
    repository1.projects.should == mapper1
    repository2.projects.should == mapper2
  end
end

describe Minimapper::Repository, "#delete_all!" do
  it "removes all records by calling delete_all on all mappers" do
    project_mapper = mock.as_null_object
    user_mapper = mock.as_null_object

    project_mapper.should_receive(:delete_all)
    user_mapper.should_receive(:delete_all)

    repository2 = described_class.build(:projects => project_mapper, :users => user_mapper)
    repository2.delete_all!
  end
end
