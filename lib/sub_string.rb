# -*- coding: utf-8 -*-

require 'sub_object'  # Gem: {SubObject}[http://rubygems.org/gems/sub_object]

# Child class of SubObject for String: SubString
#
# See for detail the full reference in the top page
# {SubString}[http://rubygems.org/gems/sub_string]
# and in {Github}[https://github.com/masasakano/sub_string]
# and also
# {SubObject}[http://rubygems.org/gems/sub_object]
# and that in {Github}[https://github.com/masasakano/sub_object]
#
# @author Masa Sakano (Wise Babel Ltd)
#
class SubString < SubObject
  # Symbol of the method that projects to (returns) the original-like instance;
  # e.g., :to_str for String. The value should be overwritten in the child class of SubObject.
  TO_SOURCE_METHOD = :to_str
  alias_method TO_SOURCE_METHOD, :to_source
end

