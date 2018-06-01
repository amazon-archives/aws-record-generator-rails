class #{test_model}
  include Aws::Record

  string_attr :uuid, hash_key = true
end
