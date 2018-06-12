
module AwsRecord
    module Generators
      class ActiveModel
        attr_reader :name
  
        def initialize(name)
          @name = name
        end
  
        # GET index
        def self.all(klass)
          "#{klass}.scan"
        end
  
        # GET show
        # GET edit
        # PATCH/PUT update
        # DELETE destroy
        def self.find(klass, params = nil)
          "#{klass}.find(#{params})"
        end
  
        # GET new
        # POST create
        def self.build(klass, params = nil)
          if params
            "#{klass}.new(#{params})"
          else
            "#{klass}.new"
          end
        end
  
        # POST create
        def save
          "#{name}.save"
        end
  
        # PATCH/PUT update
        def update(params = nil)
          "#{name}.update(#{params})"
        end
  
        # POST create
        # PATCH/PUT update
        def errors
          "#{name}.errors"
        end
  
        # DELETE destroy
        def destroy
          "#{name}.destroy"
        end
      end
    end
  end