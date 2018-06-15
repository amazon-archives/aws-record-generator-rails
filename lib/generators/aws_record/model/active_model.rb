
module AwsRecord
    module Generators
      class ActiveModel
        attr_reader :name
  
        def initialize(name)
          @name = name
        end
  
        # GET index
        def self.all(klass)
          "#{klass}.scan" # TODO No God no plz no.
        end
  
        # GET show
        # GET edit
        # PATCH/PUT update
        # DELETE destroy
        def self.find(klass, attrs)
          hkey = attrs.select{|attr| attr.options[:hash_key]}[0]
          rkey = attrs.select{|attr| attr.options[:range_key]}
          rkey = !rkey.empty? ? rkey[0] : nil

          if rkey
            """
            id = params[:id].split('-')
            #{klass}.find(#{hkey.name}: id[0], #{rkey.name}: id[1])
            """
          else
            "#{klass}.find(#{hkey.name}: params[:id])"
          end
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
          "#{name}.delete!"
        end
      end
    end
  end