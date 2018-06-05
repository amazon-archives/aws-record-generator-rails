# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not
# use this file except in compliance with the License. A copy of the License is
# located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions
# and limitations under the License.

module AwsRecord
  class SecondaryIndex

    PROJ_TYPES = %w(ALL KEYS_ONLY INCLUDE)
    attr_reader :name, :hash_key, :range_key, :projection_type

    class << self
      def parse(key_definition)
        name, index_options = key_definition.split(':')
        index_options = index_options.split(',') if index_options
        opts = parse_raw_options(index_options)

        new(name, opts)
      end

      private
        def parse_raw_options(raw_opts)
          raw_opts = [] if not raw_opts
          raw_opts.map { |opt| get_option_value(opt) }.to_h
        end

        def get_option_value(raw_option)
          case raw_option

          when /hkey\{(\w+)\}/
            return :hash_key, $1
          when /rkey\{(\w+)\}/
            return :range_key, $1
          when /proj_type\{(\w+)\}/
            return :projection_type, $1
          else
            raise ArgumentError.new("Invalid option for secondary index #{raw_option}")
          end
        end
    end

    def initialize(name, opts)
      raise ArgumentError.new("You must provide a name") if not name  
      raise ArgumentError.new("You must provide a hash key") if not opts[:hash_key]

      if opts[:projection_type]
        raise ArgumentError.new("Invalid projection type #{opts[:projection_type]}") if not PROJ_TYPES.include? opts[:projection_type]
      end

      if opts[:hash_key] == opts[:range_key]
        raise ArgumentError.new("#{opts[:hash_key]} cannot be both the rkey and hkey for gsi #{name}")
      end

      @name = name
      @hash_key = opts[:hash_key]
      @range_key = opts[:range_key]
      @projection_type = '"' + "#{opts[:projection_type]}" + '"' if opts[:projection_type]
    end
  end
end
