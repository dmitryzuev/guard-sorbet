# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :red_green_refactor, halt_on_fail: true do
  guard :minitest, all_after_pass: true, all_on_start: true do
    watch(%r{^test/(.*)/?test_(.*)\.rb$})
    watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
    watch(%r{^test/test_helper\.rb$})      { "test" }
  end

  guard :srb do
    watch(/.+\.rbi?$/)
  end
end
