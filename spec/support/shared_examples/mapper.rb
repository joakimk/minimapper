shared_examples :mapper do
  # expects repository and entity_klass to be defined

  describe "create" do
    it "sets an id on the entity" do
      entity1 = build_valid_entity
      entity1.id.should be_nil
      repository.create(entity1)
      entity1.id.should > 0

      entity2 = build_valid_entity
      repository.create(entity2)
      entity2.id.should == entity1.id + 1
    end

    it "returns the id" do
      id = repository.create(build_valid_entity)
      id.should be_kind_of(Fixnum)
      id.should > 0
    end

    it "does not store by reference" do
      entity = build_valid_entity
      repository.create(entity)
      repository.last.object_id.should_not == entity.object_id
      repository.last.name.should == "test"
    end

    it "validates the record before saving" do
      entity = entity_klass.new
      repository.create(entity).should be_false
    end
  end

  describe "find" do
    it "returns an entity matching the id" do
      entity = build_valid_entity
      repository.create(entity)
      found_entity = repository.find(entity.id)
      found_entity.name.should == "test"
      found_entity.id.should == entity.id
      found_entity.should be_kind_of(Minimapper::Entity)
    end

    it "supports string ids" do
      entity = build_valid_entity
      repository.create(entity)
      repository.find(entity.id.to_s)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      repository.create(entity)
      repository.find(entity.id).object_id.should_not == entity.object_id
      repository.find(entity.id).object_id.should_not == repository.find(entity.id).object_id
    end

    it "fails when the an entity can not be found" do
      lambda { repository.find(-1) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "first" do
    it "returns the first entity" do
      first_created_entity = build_valid_entity
      repository.create(first_created_entity)
      repository.create(build_valid_entity)
      repository.first.id.should == first_created_entity.id
      repository.first.should be_kind_of(entity_klass)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      repository.create(entity)
      repository.first.object_id.should_not == entity.object_id
      repository.first.object_id.should_not == repository.first.object_id
    end

    it "returns nil when there is no entity" do
      repository.first.should be_nil
    end
  end

  describe "last" do
    it "returns the last entity" do
      last_created_entity = build_valid_entity
      repository.create(build_valid_entity)
      repository.create(last_created_entity)
      repository.last.id.should == last_created_entity.id
      repository.last.should be_kind_of(entity_klass)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      repository.create(entity)
      repository.last.object_id.should_not == entity.object_id
      repository.last.object_id.should_not == repository.last.object_id
    end

    it "returns nil when there is no entity" do
      repository.last.should be_nil
    end
  end

  describe "count" do
    it "returns the number of entities" do
      repository.create(build_valid_entity)
      repository.create(build_valid_entity)
      repository.count.should == 2
    end
  end

  describe "update" do
    it "updates" do
      entity = build_valid_entity
      repository.create(entity)

      entity.name = "Updated"
      repository.last.name.should == "test"

      repository.update(entity)
      repository.last.id.should == entity.id
      repository.last.name.should == "Updated"
    end

    it "does not update and returns false when the entity isn't valid" do
      entity = build_valid_entity
      repository.create(entity)
      entity.name = nil

      repository.update(entity).should be_false
      repository.last.name.should == "test"
    end

    it "returns true" do
      entity = build_valid_entity
      repository.create(entity)
      repository.update(entity).should == true
    end

    it "fails when the entity does not have an id" do
      entity = build_valid_entity
      lambda { repository.update(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end

    it "fails when the entity no longer exists" do
      entity = build_valid_entity
      repository.create(entity)
      repository.delete_all
      lambda { repository.update(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "delete" do
    it "removes the entity" do
      entity = build_valid_entity
      repository.create(entity)
      repository.create(build_valid_entity)
      repository.delete(entity)
      repository.all.size.should == 1
      repository.first.id.should_not == entity.id
    end

    it "fails when the entity does not have an id" do
      entity = entity_klass.new
      lambda { repository.delete(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end

    it "fails when the entity can not be found" do
      entity = entity_klass.new(:id => -1)
      lambda { repository.delete(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "delete_by_id" do
    it "removes the entity" do
      entity = build_valid_entity
      repository.create(entity)
      repository.create(build_valid_entity)
      repository.delete_by_id(entity.id)
      repository.all.size.should == 1
      repository.first.id.should_not == entity.id
    end

    it "fails when the an entity can not be found" do
      lambda { repository.delete_by_id(-1) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "delete_all" do
    it "empties the repository" do
      repository.create(build_valid_entity)
      repository.delete_all
      repository.all.should == []
    end
  end

  private

  def build_valid_entity
    entity_klass.new(:name => 'test')
  end
end
