# typed: true
# frozen_string_literal: true

require "guard"
require "guard/plugin"
require "guard/sorbet"
require "guard/sorbet/version"
require "minitest/autorun"
require "open3"
require "shellwords"
require "sorbet-runtime"
require "rubocop/rake_task"
require "rake/testtask"
