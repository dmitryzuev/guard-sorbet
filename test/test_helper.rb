# typed: strict
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "mocha/minitest"

require "guard"
Guard.setup(notify: false, debug: false)

require "guard/sorbet"
