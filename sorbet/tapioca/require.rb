# typed: true
# frozen_string_literal: true

require "guard"
require "guard/plugin"
require "guard/sorbet"
require "guard/sorbet/version"
require "minitest/autorun"
require "mocha/minitest"
require "open3"
require "rake/testtask"
require "rubocop/rake_task"
require "shellwords"
require "sorbet-runtime"
