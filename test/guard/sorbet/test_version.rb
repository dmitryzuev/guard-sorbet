# typed: false
# frozen_string_literal: true

require "test_helper"

class Guard::Sorbet::TestSorbetVersion < Minitest::Spec
  describe "VERSION" do
    it "has version number" do
      refute_nil ::Guard::SorbetVersion::VERSION
    end
  end
end
