# = Metafata
# This library allows you to add metadata to the attributes of a class by tagging them.
# The fields can then be retreived by tag or inspected to see what groups they belong to. 
# The idea is that With fields grouped in this way you are able to metaprogram more declaratively.
#
# = Whats with the obscure names?
# Simple really, 'metadata' and 'tag' are likely to be method names that people will want
# to use :)
module Metafeta
  VERSION = 0.1

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.instance_eval do
      @_metafeta_store = {}
    end
  end

  module ClassMethods
    # Tags attributes. You can tag one or more attributes with one or more tags.
    #
    #   class Dog
    #     tag_attribute :colour,
    #                   :hair_type,
    #                   :as => :identifying_feaures, :external_features
    #     tag_attribute :temperament, :as => :behavourial_features
    #   end
    #
    def tag_attribute(*args)
      # split args into tags and attributes
      tags = args.pop
      attributes = args

      # Raise ArgumentError if :tags => :bla is missing
      raise ArgumentError, 'No tags specified' if !tags.is_a?(Hash) || !tags.has_key?(:as)

      # Allows us to pass tags as array or single tag
      tags[:as] = [tags[:as]]
      tags[:as].flatten!

      # Assign each field to its tags 
      tags[:as].each do |tag|
        metafeta_store[tag] ||= []
        metafeta_store[tag].push(*attributes).uniq!
      end

      # Syntactic sugar for defining metadata. Intended to be used as follows:
      #
      #   Dog.add_metafeta do
      #     tag_attribute :colour, :as => :identifying_features
      #   end
      #
      # This sugar allows for storing metadata definitions in a seperate file
      # in a more obvious way
      def add_metafeta(&block)
        instance_eval(&block)
      end
    end

    # A convenience method for accessing the metadata hash
    def metafeta_store
      instance_variable_get(:@_metafeta_store)
    end
  end

  # Returns true if the field has the tag specified otherwise returns false
  def attribute_tagged_with?(field, tag)
    metafeta_store.has_key?(tag) && metafeta_store[tag].include?(field)
  end

  # Returs the attributes marked up with a given tag
  def attributes_for_tag(tag)
    metafeta_store[tag]
  end

  private
    # A convenience method for accessing the metadata hash
    def metafeta_store
      self.class.metafeta_store
    end
end
