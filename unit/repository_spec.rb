require 'minimapper/repository'
require 'minimapper/memory'

module Test
  class ProjectMapper < Minimapper::Memory
  end
end

describe Minimapper::Repository, "self.build" do
  it "builds a repository" do
    repository = described_class.build(projects: Test::ProjectMapper.new)
    repository.should be_instance_of(Minimapper::Repository)
    repository.projects.should be_instance_of(Test::ProjectMapper)
  end

  it "memoizes the mappers" do
    repository = described_class.build(projects: Test::ProjectMapper.new)
    repository.projects.object_id.should == repository.projects.object_id
  end

  it "does not leak between instances" do
    repository1 = described_class.build(projects: :foo)
    repository2 = described_class.build(projects: :bar)
    repository1.projects.should == :foo
    repository2.projects.should == :bar
  end
end

describe Minimapper::Repository, "#delete_all!" do
  it "removes all records by calling delete_all on all mappers" do
    project_mapper = mock
    user_mapper = mock

    project_mapper.should_receive(:delete_all)
    user_mapper.should_receive(:delete_all)

    repository2 = described_class.build(projects: project_mapper, users: user_mapper)
    repository2.delete_all!
  end
end
