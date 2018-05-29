module AwsRecord
  class SecondaryIndex

    PROJ_TYPES = %i(ALL KEYS_ONLY INCLUDE)
    attr_reader :name, :hash_key, :range_key, :projection_type

    class << self
      def parse(key_definition)
        name, *index_options = key_definition.split(':')
        opts = parse_raw_options(index_options)

        new(name, opts)
      end

      private
        def parse_raw_options(raw_opts)
          raw_opts.map { |opt| get_option_value(opt) }.to_h
        end

        def get_option_value(raw_option)
          case raw_option

          when /hkey\{(\w+)\}/
            [:hash_key, $1.to_sym]
          when /rkey\{(\w+)\}/
            [:range_key, $1.to_sym]
          when /proj_type\{(\w+)\}/
            [:projection_type, $1.to_sym]
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

      @name = name
      @hash_key = opts[:hash_key]
      @range_key = opts[:range_key]
      @projection_type = opts[:projection_type]
    end
  end
end