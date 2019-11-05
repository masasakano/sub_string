# -*- encoding: utf-8 -*-

# @author Masa Sakano (Wise Babel Ltd)

#require 'open3'
require 'sub_object'
require 'sub_string'

$stdout.sync=true
$stderr.sync=true
# print '$LOAD_PATH=';p $LOAD_PATH

#################################################
# Unit Test
#################################################

gem "minitest"
# require 'minitest/unit'
require 'minitest/autorun'

class TestUnitSubString < MiniTest::Test
  T = true
  F = false
  SCFNAME = File.basename(__FILE__)
  EXE = "%s/../bin/%s" % [File.dirname(__FILE__), File.basename(__FILE__).sub(/^test_(.+)\.rb/, '\1')]

  def setup
  end

  def teardown
  end

  def test_sub_string01
    assert_raises(TypeError){ SubString.new [9,8], -3, 2 }

    str = 'abcdefghijklm'
    obj = SubString.new str, -5, 2
    assert_raises(TypeError){ SubString.new str, -3, :a }
    assert_equal obj,    "ij"
    assert_equal "ij",   obj
    assert( "ij"==obj )
    assert_operator obj, ">", "ii"
    assert_operator "ii", "<", obj
    assert( SubString.method_defined?(:to_str), "obj=#{obj.inspect}" )
    assert( obj.methods.include? :to_str )
    assert_equal 'ijKL', obj+"KL"
    assert_equal "IJ",   obj.upcase
    assert            obj.instance_of?(SubString)
    refute            obj.instance_of?(SubObject)
    assert            obj.respond_to?(:upcase), "upcase: to_source = (#{obj.to_source.inspect}); methods: #{obj.methods.sort.inspect}"
    assert            obj.respond_to?(:gsub), "to_source = (#{obj.to_source.inspect}); methods: #{obj.methods.sort.inspect}"
    refute            obj.respond_to?(:gsub!)
    refute            obj.respond_to?(:naiyo)
    assert_raises(NoMethodError){ obj.push 5 }
    assert_raises(NoMethodError){ obj.keep_if{} }
    assert_raises(NoMethodError){ obj.sub! }
    assert_raises(NoMethodError){ obj.replace }
    
    mutex = Mutex.new
    exclu = Thread.new {
      mutex.synchronize {
      org_verbose = $VERBOSE
      assert_output('', ''){ _ = SubString.verbose }
      begin
        $VERBOSE = true
        assert_nil          SubString.verbose
        SubString.verbose=nil;
        assert_nil          SubString.verbose
        str.sub!(/^./){|c| c.upcase}
        assert_output('', /destructively/){ obj.source }
        $VERBOSE = false
        assert_output('', /destructively/){ obj.source }
        $VERBOSE = nil
        assert_output('', ''){ obj.source }

        SubString.verbose = true
        assert_equal true,  SubString.verbose
        assert_equal true,  SubString.instance_variable_get(:@verbosity)
        assert_output('', /destructively/){ obj.source }
        SubString.verbose = false
        assert_equal false, SubString.verbose
        assert_output('', ''){ obj.source }
        $VERBOSE = true
        assert_output('', ''){ obj.source }
        SubString.verbose=nil;
        assert_output('', /destructively/){ obj.source }

        # Original String recovered, hence its hash value.
        str.sub!(/^./){|c| c.downcase}
        assert_output('', ''){ obj.source }
      ensure
        $VERBOSE = org_verbose
        SubString.verbose=nil;
      end
      }
    }
    exclu.join
  end

  def test_sub_string02
    str = 'abcdefghijklm'*20
    obj = SubString.new str, 0, 120
    str.upcase!
    siz = nil
    _, err = capture_io { siz = obj.size }
    assert_equal '..."'+"\n", err[-5..-1]
    assert_equal  60, (err.split(']')[-1].size-4)/10.0.round*10
    assert_equal 120, siz
  end

  # As in README.en.rdoc
  def test_sub_string03
    src = "abcdef"
    ss = SubString.new(src, -4, 3)  # => Similar to "abcdef"[-4,3]
    assert_operator "cde", '==', ss
    assert_equal "cde",    ss.to_s
    assert_equal "cde3p",  ss+'3p'
    assert_equal "CDE",    ss.upcase
    assert_equal "Qde",    ss.sub(/^./, 'Q')
    assert                 ss.is_a?(String)
    assert_equal "xy_cde", "xy_"+ss
  end
end # class TestUnitSubString < MiniTest::Test

