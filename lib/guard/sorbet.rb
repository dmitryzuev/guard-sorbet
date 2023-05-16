# typed: strict
# frozen_string_literal: true

require "guard/plugin"
require "guard/sorbet/version"
require "sorbet-runtime"

module Guard
  class Sorbet < Plugin
    extend T::Sig

    autoload :Runner, "guard/sorbet/runner"

    DEFAULT_OPTIONS = T.let(
      {
        all_on_start: true,
        notification: :failed,
        hide_stdout: false,
        colorize: "always"
      }.freeze,
      T::Hash[Symbol, T.untyped]
    )

    sig { params(options: T::Hash[Symbol, T.untyped]).void }
    def initialize(options = {})
      super
      @options = T.let(DEFAULT_OPTIONS.merge(@options), T::Hash[Symbol, T.untyped])
    end

    sig { returns(T.untyped) }
    def start
      run_all if @options[:all_on_start]
    end

    sig { returns(T.untyped) }
    def run_all
      UI.info "Typechecking all files"
      inspect_with_sorbet
    end

    sig { params(paths: T::Array[String]).returns(T.untyped) }
    def run_on_additions(paths)
      run_partially(paths)
    end

    sig { params(paths: T::Array[String]).returns(T.untyped) }
    def run_on_modifications(paths)
      run_partially(paths)
    end

    sig { params(paths: T::Array[String]).returns(T.untyped) }
    private def run_partially(paths)
      paths = clean_paths(paths)

      return if paths.empty?

      displayed_paths = paths.map { |path| smart_path(path) }
      UI.info "Typechecking: #{displayed_paths.join(" ")}"

      inspect_with_sorbet(paths)
    end

    sig { params(paths: T::Array[String]).returns(T.untyped) }
    private def inspect_with_sorbet(paths = [])
      runner = Runner.new(@options)
      _result, passed = runner.run(paths)

      throw :task_has_failed unless passed
    rescue StandardError => e
      UI.error "The following exception occurred while running guard-sorbet: " \
               "#{T.must(e.backtrace).first} #{e.message} (#{e.class.name})"
    end

    sig { params(paths: T::Array[String]).returns(T::Array[String]) }
    private def clean_paths(paths)
      paths = paths.dup
      paths.map! { |path| File.expand_path(path) }
      paths.uniq!
      paths.reject! do |path|
        next true unless File.exist?(path)

        included_in_other_path?(path, paths)
      end
      paths
    end

    sig { params(target_path: String, other_paths: T::Array[String]).returns(T::Boolean) }
    private def included_in_other_path?(target_path, other_paths)
      dir_paths = other_paths.select { |path| File.directory?(path) }
      dir_paths.delete(target_path)
      dir_paths.any? do |dir_path|
        target_path.start_with?(dir_path)
      end
    end

    sig { params(path: String).returns(String) }
    private def smart_path(path)
      if path.start_with?(Dir.pwd)
        Pathname.new(path).relative_path_from(Pathname.getwd).to_s
      else
        path
      end
    end
  end
end
