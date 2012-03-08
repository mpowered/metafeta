require 'lib/metafeta.rb'

describe Metafeta do
  describe '#tag_attribute' do
    before(:each) do
      class DogA
        include Metafeta
        tag_attribute :colour, :hair_type, :snout_length, :as => [:external_features, :identifying_features]
      end
    end
    it "adds tags to the fields specified" do
      DogA.new.attribute_tagged_with?(:colour, :identifying_features).should be_true
    end

    it "raises an error when no :as options is specified" do
      lambda {DogA.tag_attribute :colour, :hair_type}.should raise_error(ArgumentError, 'No tags specified')
    end

    it "doesn't fail when a single tag is passed in" do
      lambda {DogA.tag_attribute :colour, :as => :identifying_features}.should_not raise_error
    end
  end

  describe '#attribute_tagged_with?' do
    before(:each) do
      class DogB
        include Metafeta
        @_metafeta_store = {:identifying_features => [:colour]}
      end
    end

    it "returns true if the attribute has been tagged specified tag" do
      DogB.new.attribute_tagged_with?(:colour, :identifying_features).should be_true
    end

    it "returns false if the attribute has NOT been tagged with the specified tag" do
      DogB.new.attribute_tagged_with?(:colour, :behavourial_features).should be_false
    end
  end

  describe '#metafeta_store' do
    before(:each) do
      class DogD
        include Metafeta
        @_metafeta_store = {:a_tag => [:colours]}
      end
    end
    it "returns the metafeta_store hash" do
      DogD.new.send(:metafeta_store).should == {:a_tag => [:colours]}
    end
  end

  describe '.metafeta_store' do
    before(:each) do
      class DogE
        include Metafeta
        @_metafeta_store = {:a_tag => [:colours]}
      end
    end
    it "returns the metafeta_store hash" do
      DogE.metafeta_store.should == {:a_tag => [:colours]}
    end

    context "when a subclass has no metadata defined" do
      before(:each) do
        class DogEA
          include Metafeta
          tag_attribute :name, :as => :identifying
        end

        class DogEASub < DogEA; end
      end

      it "inherits it's superclass's metadata" do
        DogEASub.metafeta_store.should == {:identifying => [:name]}
      end
    end

    context "when a subclass has metadata" do
      before(:each) do
        class DogEB
          include Metafeta
          tag_attribute :name, :as => :identifying
        end

        class DogEBSub < DogEB
          tag_attribute :colour, :as => :identifying
        end
      end

      it "mixes it's metadata with that which it inherited" do
        DogEBSub.metafeta_store.should == {:identifying => [:name, :colour]}
      end

      it "does not mix the subclass metadata into the superclass's metadata" do
        DogEB.metafeta_store.should == {:identifying => [:name]}
      end
    end
  end

  describe '#attributes_for_tag' do
    before(:each) do
      class DogF
        include Metafeta
        tag_attribute :colour, :fur, :as => :image_attributes
      end
    end

    it "returns the attributes for a given tag" do
      DogF.new.attributes_for_tag(:image_attributes).should == [:colour, :fur]
    end
  end

  describe '.add_metafeta' do
    before(:each) do
      class DogG
        include Metafeta
      end
    end
    it "allows us to call class methods in context of the class" do
      lambda do
        DogG.add_metafeta do
          tag_attribute :colour, :as => :external_stuff
        end
      end.should_not raise_error
      DogG.new.attribute_tagged_with?(:colour, :external_stuff).should be_true
    end
  end

  describe '.clear_tag' do
    context "when a superclass has metadata" do
      before(:each) do
        class DogF
          include Metafeta
          tag_attribute :colour, :as => :external_features
        end

        class DogFSub
          include Metafeta
          clear_tag(:fur)
          tag_attribute :fur, :as => :external_features
        end
      end

      it "clears the metadata in the class its called in" do
        DogFSub.metafeta_store.should == {:external_features => [:fur]}
      end

      it "does not clear the metadata in the superclass" do
        DogF.metafeta_store.should == {:external_features => [:colour]}
      end
    end
  end
end
