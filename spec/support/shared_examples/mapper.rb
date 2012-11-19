shared_examples :mapper do
  # expects mapper and entity_class to be defined

  describe "#create" do
    it "sets an id on the entity" do
      entity1 = build_valid_entity
      entity1.id.should be_nil
      mapper.create(entity1)
      entity1.id.should > 0

      entity2 = build_valid_entity
      mapper.create(entity2)
      entity2.id.should == entity1.id + 1
    end

    it "returns the id" do
      id = mapper.create(build_valid_entity)
      id.should be_kind_of(Fixnum)
      id.should > 0
    end

    it "does not store by reference" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.last.object_id.should_not == entity.object_id
      mapper.last.attributes[:name].should == "test"
    end

    it "validates the record before saving" do
      entity = entity_class.new
      def entity.valid?
        false
      end
      mapper.create(entity).should be_false
    end
  end

  describe "#find" do
    it "returns an entity matching the id" do
      entity = build_valid_entity
      mapper.create(entity)
      found_entity = mapper.find(entity.id)
      found_entity.attributes[:name].should == "test"
      found_entity.id.should == entity.id
      found_entity.should be_kind_of(Minimapper::Entity::Core)
    end

    it "supports string ids" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find(entity.id.to_s)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find(entity.id).object_id.should_not == entity.object_id
      mapper.find(entity.id).object_id.should_not == mapper.find(entity.id).object_id
    end

    it "fails when an entity can not be found" do
      lambda { mapper.find(-1) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "#find_by_id" do
    it "returns an entity matching the id" do
      entity = build_valid_entity
      mapper.create(entity)
      found_entity = mapper.find_by_id(entity.id)
      found_entity.attributes[:name].should == "test"
      found_entity.id.should == entity.id
      found_entity.should be_kind_of(Minimapper::Entity::Core)
    end

    it "supports string ids" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find_by_id(entity.id.to_s)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find_by_id(entity.id).object_id.should_not == entity.object_id
      mapper.find_by_id(entity.id).object_id.should_not == mapper.find_by_id(entity.id).object_id
    end

    it "returns nil when an entity can not be found" do
      mapper.find_by_id(-1).should be_nil
    end
  end

  describe "#all" do
    it "returns all entities in undefined order" do
      first_created_entity = build_valid_entity
      second_created_entity = build_valid_entity
      mapper.create(first_created_entity)
      mapper.create(second_created_entity)
      all_entities = mapper.all
      all_entities.map(&:id).should include(first_created_entity.id)
      all_entities.map(&:id).should include(second_created_entity.id)
      all_entities.first.should be_kind_of(Minimapper::Entity::Core)
    end

    it "does not return the same instances" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.all.first.object_id.should_not == entity.object_id
      mapper.all.first.object_id.should_not == mapper.all.first.object_id
    end
  end

  describe "#first" do
    it "returns the first entity" do
      first_created_entity = build_valid_entity
      mapper.create(first_created_entity)
      mapper.create(build_valid_entity)
      mapper.first.id.should == first_created_entity.id
      mapper.first.should be_kind_of(entity_class)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.first.object_id.should_not == entity.object_id
      mapper.first.object_id.should_not == mapper.first.object_id
    end

    it "returns nil when there is no entity" do
      mapper.first.should be_nil
    end
  end

  describe "#last" do
    it "returns the last entity" do
      last_created_entity = build_valid_entity
      mapper.create(build_valid_entity)
      mapper.create(last_created_entity)
      mapper.last.id.should == last_created_entity.id
      mapper.last.should be_kind_of(entity_class)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.last.object_id.should_not == entity.object_id
      mapper.last.object_id.should_not == mapper.last.object_id
    end

    it "returns nil when there is no entity" do
      mapper.last.should be_nil
    end
  end

  describe "#count" do
    it "returns the number of entities" do
      mapper.create(build_valid_entity)
      mapper.create(build_valid_entity)
      mapper.count.should == 2
    end
  end

  describe "#update" do
    it "updates" do
      entity = build_valid_entity
      mapper.create(entity)

      entity.attributes = { :name => "Updated" }
      mapper.last.attributes[:name].should == "test"

      mapper.update(entity)
      mapper.last.id.should == entity.id
      mapper.last.attributes[:name].should == "Updated"
    end

    it "does not update and returns false when the entity isn't valid" do
      entity = build_valid_entity
      mapper.create(entity)

      def entity.valid?
        false
      end

      mapper.update(entity).should be_false
      mapper.last.attributes[:name].should == "test"
    end

    it "returns true" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.update(entity).should == true
    end

    it "fails when the entity does not have an id" do
      entity = build_valid_entity
      lambda { mapper.update(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end

    it "fails when the entity no longer exists" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.delete_all
      lambda { mapper.update(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "#delete" do
    it "removes the entity" do
      entity = build_valid_entity
      removed_entity_id = entity.id
      mapper.create(entity)
      mapper.create(build_valid_entity)
      mapper.delete(entity)
      mapper.all.size.should == 1
      mapper.first.id.should_not == removed_entity_id
    end

    it "clears the entity id" do
      entity = build_valid_entity
      mapper.create(entity)
      entity.id.should_not be_nil
      mapper.delete(entity)
      entity.id.should be_nil
    end

    it "fails when the entity does not have an id" do
      entity = entity_class.new
      lambda { mapper.delete(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end

    it "fails when the entity can not be found" do
      entity = entity_class.new
      entity.id = -1
      lambda { mapper.delete(entity) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "#delete_by_id" do
    it "removes the entity" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.create(build_valid_entity)
      mapper.delete_by_id(entity.id)
      mapper.all.size.should == 1
      mapper.first.id.should_not == entity.id
    end

    it "fails when an entity can not be found" do
      lambda { mapper.delete_by_id(-1) }.should raise_error(Minimapper::Common::CanNotFindEntity)
    end
  end

  describe "#delete_all" do
    it "empties the mapper" do
      mapper.create(build_valid_entity)
      mapper.delete_all
      mapper.all.should == []
    end
  end

  private

  def build_valid_entity
    entity = entity_class.new
    entity.attributes = { :name => 'test' }
    entity
  end
end
