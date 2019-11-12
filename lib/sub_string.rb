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
  # e.g., :to_str for String. The value should be overwritten in the child class of {SubObject}, namely this class {SubString} in this case.
  TO_SOURCE_METHOD = :to_str
  alias_method TO_SOURCE_METHOD, :to_source

  # Returns a new instance of SubString equivalent to source[ pos, size ]
  #
  # Difference from the original SubObject is the defaults are set for
  # the second and third parameters.
  #
  # If the third parameter is nil, it is set as the maximum size possible
  # counted from pos (the starting position)
  #
  # @param source [String]
  # @param pos [Integer] Starting character index position.
  # @param size [Integer, nil] Size of the substring to make.
  # @param attr: [Object] user-specified arbitrary object
  def initialize(source, pos=0, size=nil, attr: nil)
    size ||= ((pos >= 0) ? source.size - pos : -pos)
    super source, pos, size, attr: attr
  end
end

# Function version of {SubString#initialize}
#
# @param (see SubString#initialize)
def SubString(*rest, **kwd)
  SubString.new(*rest, **kwd)
end

