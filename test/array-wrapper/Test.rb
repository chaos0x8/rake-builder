require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/rake-builder'

module RakeBuilder
  class TestArrayWrapper < Test::Unit::TestCase
    def self.shouldRaiseOn cls
      proc {
        should("raise on #{cls}") {
          assert_raise(TypeError) {
            cls[@sut]
          }
        }
      }
    end

    def self.shouldRespondTo cls, expected
      proc {
        should("respond to #{cls}") {
          assert_equal(expected, cls[@sut])
        }
      }
    end

    def self.shouldHaveMethod method
      proc {
        should("have method :#{method}") {
          assert(@sut.respond_to? method)
        }
      }
    end

    def libraryMock
      ret = mock('library')
      ret.stubs(:_names_ => ['names'], :_build_ => ['build'])
      ret
    end

    @@indexes = {}

    {
      Sources.new(['main.cpp'], flags: [], includes: [], requirements: []) => [
        { :shouldRespondTo => [Names, ['.obj/main.cpp.o']] },
        { :shouldRespondTo => [Build, ['.obj/main.cpp.o']] },
        { :shouldHaveMethod => [:-] }
      ],
      Requirements.new(['main.cpp']) => [
        { :shouldRespondTo => [Names, ['main.cpp']] },
        { :shouldRaiseOn => [Build] }
      ],
      InstallPkgList.new(['foo']) => [
        { :shouldRaiseOn => [Names] },
        { :shouldRaiseOn => [Build] }
      ],
      Includes.new(['dir']) => [
        { :shouldRaiseOn => [Names] },
        { :shouldRespondTo => [Build, ['-Idir']] }
      ],
      Flags.new(['--std=c++11', '--std=c++17', '--std=c++14', 'flag1', 'flag2']) => [
        { :shouldRaiseOn => [Names] },
        { :shouldRespondTo => [Build, ['flag1', 'flag2', '--std=c++17']] }
      ],
      Flags.new(['--std=c++11', '--std=c++20', '--std=c++0x']) => [
        { :shouldRespondTo => [Build, ['--std=c++20']] }
      ],
      Track.new(['foo', 'bar']) => [
        { :shouldRespondTo => [Names, ['foo', 'bar']] },
        { :shouldRaiseOn => [Build] }
      ],
      proc { Libs.new(['libhello.a', libraryMock]) } => [
        { :shouldRespondTo => [Names, ['names']] },
        { :shouldRespondTo => [Build, ['libhello.a', 'build']] }
      ]
    }.each { |sut, tests|
      @@indexes[sut.class] ||= 0
      index = @@indexes[sut.class]
      @@indexes[sut.class] += 1

      context("RakeBuilder::Test#{sut.class}/#{index}") {
        setup {
          if sut.respond_to? :call
            @sut = instance_eval(&sut)
          else
            @sut = sut
          end
        }

        tests.each { |spec|
          spec.each { |test, args|
            merge_block(&send(test, *args));
          }
        }

        merge_block(&shouldHaveMethod(:each))
        merge_block(&shouldHaveMethod(:<<))
      }
    }
  end
end

