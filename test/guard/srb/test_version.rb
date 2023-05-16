# typed: false
# frozen_string_literal: true

require "test_helper"

class Guard::Srb::TestSrbVersion < Minitest::Spec
  describe "VERSION" do
    it "has version number" do
      refute_nil ::Guard::SrbVersion::VERSION
    end
  end
end
