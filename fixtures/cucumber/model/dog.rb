require 'aws-record'

class Dog
  include Aws::Record
  extend ActiveModel::Naming

  string_attr :id, hash_key: true
  string_attr :name
  boolean_attr :is_good_boy
  
  # Scaffolding helpers
  def to_model
    self
  end

  def to_param
    return nil unless persisted?

    hkey = public_send(self.class.hash_key)
    if self.class.range_key
        rkey = public_send(self.class.range_key)
        "#{CGI.escape(hkey)}&#{CGI.escape(rkey)}"
    else
        "#{CGI.escape(hkey)}"
    end
  end
end
