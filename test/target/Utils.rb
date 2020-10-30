module Utils
  def self.shouldSetDesc
    proc {
      [:desc=, :description=].each { |tag|
        should("set description/#{tag}") {
          $stderr.stubs(:puts)

          sut = @sut.class.new { |t|
            t.name = 'task'
            t.send(tag, 'foo')
          }

          assert_equal('foo', sut.description)
        }
      }
    }
  end

  def self.shouldSetReqs
    proc {
      should('set requirements') {
        sut = @sut.class.new { |t|
          t.name = 'task'
          t.requirements << :xxx << 'yyy'
        }

        assert_equal(['xxx', 'yyy'], Names[sut.requirements])
      }
    }
  end
end
