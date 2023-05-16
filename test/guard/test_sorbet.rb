# typed: strict
# frozen_string_literal: true

require "test_helper"

class Guard::TestSorbet < Minitest::Test
  extend T::Sig

  sig { void }
  def test_that_it_has_a_version_number
    refute_nil ::Guard::SorbetVersion::VERSION
  end

  sig { void }
  def test_it_does_something_useful
    assert false
  end
end
