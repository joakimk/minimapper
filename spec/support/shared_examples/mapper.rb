shared_examples :mapper do
  # expects repository and entity_class to be defined

  describe "#create" do
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
      repository.last.attributes[:name].should == "test"
    end

    it "validates the record before saving" do
      entity = entity_class.new
      def entity.valid?
        false
      end
      repository.create(entity).should be_false
    end
  end

  describe "#find" do
    it "returns an entity matching the id" do
      entity = build_valid_entity
      repository.create(entity)
      found_entity = repository.find(entity.id)
      found_entity.attributes[:name].should == "test"
      found_entity.id.should == entity.id
      found_entity.should be_kind_of(Minimapper::Entity::Core)
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

    it "fails when an entity can not be found" do
      lambda { repository.find(-1) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "#find_by_id" do
    it "returns an entity matching the id" do
      entity = build_valid_entity
      repository.create(entity)
      found_entity = repository.find_by_id(entity.id)
      found_entity.attributes[:name].should == "test"
      found_entity.id.should == entity.id
      found_entity.should be_kind_of(Minimapper::Entity::Core)
    end

    it "supports string ids" do
      entity = build_valid_entity
      repository.create(entity)
      repository.find_by_id(entity.id.to_s)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      repository.create(entity)
      repository.find_by_id(entity.id).object_id.should_not == entity.object_id
      repository.find_by_id(entity.id).object_id.should_not == repository.find_by_id(entity.id).object_id
    end

    it "returns nil when an entity can not be found" do
      repository.find_by_id(-1).should be_nil
    end
  end

  describe "#all" do
    it "returns all entities in undefined order" do
      first_created_entity = build_valid_entity
      second_created_entity = build_valid_entity
      repository.create(first_created_entity)
      repository.create(second_created_entity)
      all_entities = repository.all
      all_entities.map(&:id).should include(first_created_entity.id)
      all_entities.map(&:id).should include(second_created_entity.id)
      all_entities.first.should be_kind_of(Minimapper::Entity::Core)
    end

    it "does not return the same instances" do
      entity = build_valid_entity
      repository.create(entity)
      repository.all.first.object_id.should_not == entity.object_id
      repository.all.first.object_id.should_not == repository.all.first.object_id
    end
  end

  describe "#first" do
    it "returns the first entity" do
      first_created_entity = build_valid_entity
      repository.create(first_created_entity)
      repository.create(build_valid_entity)
      repository.first.id.should == first_created_entity.id
      repository.first.should be_kind_of(entity_class)
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

  describe "#last" do
    it "returns the last entity" do
      last_created_entity = build_valid_entity
      repository.create(build_valid_entity)
      repository.create(last_created_entity)
      repository.last.id.should == last_created_entity.id
      repository.last.should be_kind_of(entity_class)
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

  describe "#count" do
    it "returns the number of entities" do
      repository.create(build_valid_entity)
      repository.create(build_valid_entity)
      repository.count.should == 2
    end
  end

  describe "#update" do
    it "updates" do
      entity = build_valid_entity
      repository.create(entity)

      entity.attributes = { :name => "Updated" }
      repository.last.attributes[:name].should == "test"

      repository.update(entity)
      repository.last.id.should == entity.id
      repository.last.attributes[:name].should == "Updated"
    end

    it "does not update and returns false when the entity isn't valid" do
      entity = build_valid_entity
      repository.create(entity)

      def entity.valid?
        false
      end

      repository.update(entity).should be_false
      repository.last.attributes[:name].should == "test"
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

  describe "#delete" do
    it "removes the entity" do
      entity = build_valid_entity
      removed_entity_id = entity.id
      repository.create(entity)
      repository.create(build_valid_entity)
      repository.delete(entity)
      repository.all.size.should == 1
      repository.first.id.should_not == removed_entity_id
    end

    it "clears the entity id" do
      entity = build_valid_entity
      repository.create(entity)
      entity.id.should_not be_nil
      repository.delete(entity)
      entity.id.should be_nil
    end

    it "fails when the entity does not have an id" do
      entity = entity_class.new
      lambda { repository.delete(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end

    it "fails when the entity can not be found" do
      entity = entity_class.new
      entity.id = -1
      lambda { repository.delete(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "#delete_by_id" do
    it "removes the entity" do
      entity = build_valid_entity
      repository.create(entity)
      repository.create(build_valid_entity)
      repository.delete_by_id(entity.id)
      repository.all.size.should == 1
      repository.first.id.should_not == entity.id
    end

    it "fails when an entity can not be found" do
      lambda { repository.delete_by_id(-1) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "#delete_all" do
    it "empties the repository" do
      repository.create(build_valid_entity)
      repository.delete_all
      repository.all.should == []
    end
  end

  private

  def build_valid_entity
    entity = entity_class.new
    entity.attributes = { :name => 'test' }
    entity
  end
end
