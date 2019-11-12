
# SubString - Duck-typed String class with negligible memory use

## Summary

Class {SubString} that expresses Ruby sub-String but taking up negligible
memory space, as its instance holds the positional information only.  It
behaves exactly like String (duck-typing), except destructive modification is
prohibited.  If the original string is destructively modified, warning is
issued.  Also, as a bonus, an arbitrary object can be associated with
instances of this class with `SubString#attr`.

On the surface, this is a String version of the class MatchSkeleton
[match_skeleton](https://rubygems.org/gems/match_skeleton) (also in 
[Github](https://github.com/masasakano/match_skeleton)), which is an
alternative and much memorly-lighter version of MatchData.

For the detailed background concept (and algorithm), see the reference page of
the generalized parent class, SubObject, either at the [Ruby Gems page](http://rubygems.org/gems/sub_object) or in
[Github](https://github.com/masasakano/sub_object) .

The full package of this class is found also in [SubString Ruby Gems page](http://rubygems.org/gems/sub_string) and in
[Github](https://github.com/masasakano/sub_string)

## Description

This class takes three parameters in the initialization: **source**, **pos**
(starting positional character-index), and **size** (of the substring of the
original String **source**.

```ruby
SubString.new( source, pos=0, size=nil, attr: arbitrary_object )
```

The constructed instance of this class keeps only these three pieces of
information, plus user-supplied instance-specific additional information
`attr`, (plus a hash value, strictly speaking), and hence uses negligible
internal memory space on its own, unlike the Ruby default `String#[ i, j ]` .

Note that the default of `pos` is 0, and negative values are allowed for it
just like `String#[ -2, 1 ]` .   If the size is unspecified, the maximum
possible size for `source` counted from `pos` is used.

Then, whenever it is referred to, it reconstructs the original sub-String
object:

```ruby
source[pos, size]
```

and works exactly like **source**
([duck-typing](https://en.wikipedia.org/wiki/Duck_typing)).

Note `attr` option is optional and to set an arbitrary object as an instance
variable.  The default value is nil. It can be reset any time later with the
setter method of `SubString#attr=`. To store an arbitrary number of pieces of
information, a Hash instance would be convenient.

As an example, the child class
[SubString](http://rubygems.org/gems/sub_string) (provided as a different Gem)
works as:

```ruby
src = "abcdef"
ss = SubString(src, -4, 3, attr: (5..6)) # => Short form of SubString.new()
             # => Similar to "abcdef"[-4,3]
print ss     # => "cde" (STDOUT)
ss+'3p'      # => "cde3p"
ss.upcase    # => "CDE"
ss.sub(/^./, 'Q') # => "Qde"
ss.is_a?(String)  # => true
"xy_"+ss     # => "xy_cde"
"cde" == ss  # => true
ss.attr      # => (5..6)  # user-specified instance-specific additional information
```

Internally the instance holds the source object.  Therefore, as long as the
instance is alive, the source object is never garbage-collected (GC).

### Instance methods

The following is the instance methods of this class that do not exist in
String.  All are inherited from the parent
[SubObject](http://rubygems.org/gems/sub_object) class.

<dl>
<dt>#source()</dt>
<dd>   Returns the first argument (&lt;tt&gt;source&lt;/tt&gt; String) given in initialization. The
    returned value is dup-ped and &lt;strong&gt;frozen&lt;/strong&gt;.</dd>
<dt>#pos()</dt>
<dd>   Returns the second argument (positional index) given in initialization.</dd>
<dt>#subsize()</dt>
<dd>   Returns the third argument (size) given in initialization.  Equivalent to
    the method &lt;tt&gt;#size&lt;/tt&gt;.</dd>
<dt>#pos_size()</dt>
<dd>   Returns the two-component array of &lt;tt&gt;[pos, subsize]&lt;/tt&gt;</dd>
<dt>#to_source()</dt>
<dd>   Returns the instance projected with &lt;tt&gt;to_src&lt;/tt&gt;</dd>
<dt>#attr=()</dt>
<dd>   Setter of the user-defined instance variable.</dd>
<dt>#attr()</dt>
<dd>   Getter of the user-defined instance variable.  The default is nil</dd>
</dl>



In addition, `#inspect` is redefined.

Any public methods but destructive ones that are defined for the `source` can
be applied to the instance of this class.

### Potential use

Each sub-String in Ruby like `String#[ i, j ]` or `String#[ i..j ]` takes up
memory according to the length of the sub-String.  Consider an example:

```ruby
src = "Some very extremely lengthy string.... (snipped)".
sub = src[1..-1]
```

The variable `sub` uses up about the same memory of `src`. If a great number
of `sub` is created and held alive, the total memory used by the process can
become quicly multifold, even by orders of magnitude.

This is where this class comes in handy.  For example, a parsing program
applied to a huge text document with a complex grammar may hold a number of
such String variables.  By using this class instead of String, it can save
some valuable memory.

Note this class also offers a function to associate an arbitrary object with
it with the setter and getter methods of `SubString#attr=` and
`SubString#attr` (which are inherited methods from the parent class
[SubObject](http://rubygems.org/gems/sub_object) like the others).

### Warning about destructive methods to this instance or worse, to the source

If the source object has been destructively altered, such as with the
destructive method `clear`, the corresponding object of this class is likely
not to make sense any more.  This class can detect such destructive
modification (using the method `Object#hash`) and issues a warning whenever it
is accessed after the source object has been destructively altered, unless the
appropriate global settings (see the next section) are set to suppress it.

Similarly, because this class supplies an object with the filter
`String#to_str` when it receives any message (i.e., method), it does not make
sense to apply a destructive change on the instance of this class. Therefore,
whenever a destructive method (such as, `String#sub!` and `String#replace` or
even `String#force_encoding`) is applied to an instance of this class, it
raises NoMethodError exception (or tries to with the best effort).  The
routine to identify the destructive method relies thoroughly on the method
name. The methods ending with "!" are regarded as destructive and all the
built-in destructive methods of String (as of Ruby 2.6.5).

If a user library adds destructive methods with the name not ending with "!"
in the String class, you can register it in the inherited class constant
DESTRUCTIVE_METHODS so the instances of this class will recognize them (Note
that it is recommended to use a destructive method for it, perhaps with one of
`Array#<<`, `Array#append`, `Array#push`, `Array#concat` etc). The reference
of the parent [SubObject](http://rubygems.org/gems/sub_object) class describes
the detail of the mechanism of how it works (if you are interested).

Note that if a (user-defined) desturctive method of String passes the check by
this class objects, the result is most likely to be different from intended. 
It certainly never alters this instance destructively, and the returned value
may be not like the expected value.

### Suppressing the warning

This class objects issues a warning in default every time it detects the
**source** String object has been destructively modified.  My best advice is,
never alter the **source** object destructively!  It makes no sense to use
this object in such a case.

However if you want to suppress the warning message, set the Ruby global
variable `$VERBOSE` to nil.  Alternatively, you can control it with a class
instance variable as

```ruby
SubString.verbose       # => getter
SubString.verbose=true  # => setter
```

If it is set either TRUE or FALSE, this verbosity level has a priority,
regardless of the value of `$VERBOSE`. In default it is nil and $VERBOSE is
referred to.

## Install

This script requires [Ruby](http://www.ruby-lang.org) Version 2.0 or above. 
Also, all this library depends on [SubObject (sub_object)](https://rubygems.org/gems/sub_object), which you can find in
RubyGems.

You can install the packages of both this library and SubObject with the usual
Ruby gem command. Or, alternatively, download them and put the library files
in one of your Ruby library search paths.

## Developer's note

The master of this README file as well as the entire package is found in
[RubyGems/sub_string](https://rubygems.org/gems/sub_string)

The source code is maintained also in
[Github](https://github.com/masasakano/sub_string) with no intuitive interface
for annotation but with easily-browsable
[ChangeLog](https://github.com/masasakano/sub_string/blob/master/ChangeLog)

### Tests

The Ruby codes under the directory `test/` are the test scripts. You can run
them from the top directory as `ruby test/test_****.rb` or simply run `make
test`.

## Known bugs and Todo items

*   This class ignores any optional (keyword) parameters for the methods of
    the original String class.  It is due to the fact Ruby
    [BasicObject#method_missing](https://ruby-doc.org/core-2.6.5/BasicObject.html#method-i-method_missing) does not take them into account as of
    Ruby-2.6.5.  It may change in future versions of Ruby. As far as the Ruby
    built-in methods of String are concerned, it does not matter because none
    of them uses one.  However, if String has methods of this kind defined by
    a user or in external library, it may encounter a trouble.


## Copyright

<dl>
<dt>Author</dt>
<dd>   Masa Sakano &lt; info a_t wisebabel dot com &gt;</dd>
<dt>Versions</dt>
<dd>   The versions of this package follow Semantic Versioning (2.0.0)
    http://semver.org/</dd>
<dt>License</dt>
<dd>   MI</dd>
</dl>



