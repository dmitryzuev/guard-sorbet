# typed: strict
# frozen_string_literal: true

require "test_helper"

class Guard::TestSorbet < Minitest::Test
  extend T::Sig

  sig { void }
  def test_that_it_has_a_version_number
    refute_nil ::Guard::SorbetVersion::VERSION
  end

  describe "#options" do
    describe "by default" do
      it "has default options" do
        guard = Guard::Sorbet.new({})
        options = guard.options

        assert_equal(true, options[:all_on_start])
        assert_equal(:failed, options[:notification])
        assert_equal(false, options[:hide_stdout])
        assert_equal("always", options[:colorize])
        assert_nil(options[:cmd])
        assert_nil(options[:cli])
        assert_nil(options[:config])
      end
    end
  end
end
