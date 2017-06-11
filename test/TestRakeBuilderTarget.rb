#!/usr/bin/ruby

# \author <https://github.com/chaos0x8>
# \copyright
# Copyright (c) 2016 - 2017, <https://github.com/chaos0x8>
#
# \copyright
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# \copyright
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/RakeBuilder'

class TestTarget < Test::Unit::TestCase
  def sourceFileMock
    result = mock()
    result.expects(:kind_of?).returns(false).at_least(0)
    result.expects(:kind_of?).with(RakeBuilder::SourceFile).returns(true).at_least(0)
    result
  end

  [ Executable, Library ].each { |_class_|
    context("Test#{_class_}") {
      should('raise when name is missing') {
        assert_raise(RakeBuilder::MissingAttribute) {
          _class_.new(sources: [ 'main.cpp' ])
        }
      }

      should('raise when sources are missing') {
        assert_raise(RakeBuilder::MissingAttribute) {
          _class_.new(name: 'name')
        }
      }

      should('not create source rule when existing source is given') {
        RakeBuilder::SourceFile.expects(:new).at_most(0)

        _class_.new(name: 'name') { |t|
          t.sources << sourceFileMock
        }
      }

      context('with some sources') {
        setup {
          @sources = [ 'main.cpp', 'library.cpp' ]
          @mocks = @sources.collect { |x| ".obj/#{x.ext('.o')}" }
        }

        should('create source rules using constructor') {
          RakeBuilder::SourceFile.expects(:new).with { |x| x[:name] == 'main.cpp' }.returns(sourceFileMock)
          RakeBuilder::SourceFile.expects(:new).with { |x| x[:name] ==  'library.cpp' }.returns(sourceFileMock)

          _class_.new(name: 'name', sources: @sources)
        }

        should('create source rules using yielded self') {
          RakeBuilder::SourceFile.expects(:new).with { |x| x[:name] == 'main.cpp' }.returns(sourceFileMock)
          RakeBuilder::SourceFile.expects(:new).with { |x| x[:name] == 'library.cpp'}.returns(sourceFileMock)

          _class_.new(name: 'name') { |t|
            t.sources << @sources
          }
        }

        should('be convertable to names') {
          sut = _class_.new(name: 'name') { |t|
            t.expects(:file).at_least(0)

            t.sources << @sources
          }

          assert_equal(['name', '.obj/main.o', '.obj/library.o'], Names[sut])
        }

        should('be convertable to names with other Target') {
          lib = Library.new(name: 'libname.a') { |t|
            t.sources << 'hello.cpp'
          }

          sut = _class_.new(name: 'name', sources: 'main.cpp', libs: [ lib, '-lpthread' ])

          assert_equal(['name', '.obj/main.o', 'libname.a', '.obj/hello.o'], Names[sut])
        } if _class_ != Library

        should('be convertable to build') {
          sut = _class_.new(name: 'name') { |t|
            t.sources << 'hello.cpp'
          }

          assert_equal(['name'], Build[sut])
        } if _class_ != Executable

        should('create exec rule') {
          _class_.new(name: 'name') { |t|
            t.expects(:file).at_least(0)
            t.expects(:file).with('name' => [ '.obj/main.o', '.obj/library.o' ])

            t.sources << @sources
          }
        }

        should('create rules with requirements') {
          RakeBuilder::SourceFile.expects(:new).with { |x|
            x[:name] == 'main.cpp' and
            Names[x[:requirements]] == ['hello.hpp']
          }.returns('.obj/main.o')

          _class_.new(name: 'name', requirements: 'hello.hpp') { |t|
            t.expects(:file).with('name' => [ 'hello.hpp' ,'.obj/main.o' ] )

            t.sources << 'main.cpp'
          }
        }

        should('remove duplicated flags') {
          _class_.new(name: 'name') { |t|
            t.expects(:file).at_least(0)

            t.sources << @sources
            t.flags << [ '-pthread', '-DNDEBUG', '-pthread', '--std=c++11' ]

            assert_equal(['-pthread', '-DNDEBUG', '--std=c++11'].sort, Build[t.flags].sort)
          }
        }

        should('merge duplicated \'--std=\' like flags') {
          _class_.new(name: 'name') { |t|
            t.expects(:file).at_least(0)

            t.sources << @sources
            t.flags << [ '--std=c++11', '--std=c++14' ]
            t.flags << [ '-std=c++11', '-std=c++14' ]

            assert_equal(['--std=c++14'], Build[t.flags])
          }
        }

        context('with pkgs') {
          setup {
            require_relative 'Stubs/PkgsStub'
            @pkgs = PkgsStub.new
            RakeBuilder::Pkgs.expects(:new).returns(@pkgs).with { |pkgs, flags:, libs:|
              @pkgs.init(pkgs, flags, libs)
            }
          }

          should('add flags from pkg') {
            _class_.new(name: 'name') { |t|
              t.expects(:file).at_least(0)

              @pkgs.expects(:<<).with('ruby') {
                @pkgs.flags << 'flag'
              }

              t.sources << @sources
              t.pkgs << 'ruby'

              assert_equal(['flag'], Build[t.flags])
            }
          }

          should('add libs from pkg') {
            _class_.new(name: 'name') { |t|
              t.expects(:file).at_least(0)

              @pkgs.expects(:<<).with('ruby') {
                @pkgs.libs << 'lib'
              }

              t.sources << @sources
              t.pkgs << 'ruby'

              assert_equal(['lib'], Build[t.libs])
            }
          }
        }
      }
    }
  }
end


