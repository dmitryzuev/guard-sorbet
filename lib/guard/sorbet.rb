# typed: strict
# frozen_string_literal: true

# require_relative "sorbet/version"

require "guard/plugin"
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

    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    sig { params(options: T::Hash[Symbol, T.untyped]).void }
    def initialize(options = {})
      super
      @options = T.let(DEFAULT_OPTIONS.merge(@options), T::Hash[Symbol, T.untyped])
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    sig { returns(T.untyped) }
    def start
      run_all if @options[:all_on_start]
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    # sig { returns(T.untyped) }
    # def stop
    #   nil
    # end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    # sig { returns(T.untyped) }
    # def reload
    #   nil
    # end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    sig { returns(T.untyped) }
    def run_all
      UI.info "Typechecking all files"
      inspect_with_sorbet([], run_all: true)
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    sig { params(paths: T::Array[String]).returns(T.untyped) }
    def run_on_additions(paths)
      run_partially(paths)
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    sig { params(paths: T::Array[String]).returns(T.untyped) }
    def run_on_modifications(paths)
      run_partially(paths)
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    # sig { params(paths: T::Array[String]).returns(T.untyped) }
    # def run_on_removals(paths)
    #   run_partially(paths)
    # end

    sig { params(paths: T::Array[String]).returns(T.untyped) }
    private def run_partially(paths)
      paths = clean_paths(paths)

      return if paths.empty?

      displayed_paths = paths.map { |path| smart_path(path) }
      UI.info "Typechecking: #{displayed_paths.join(" ")}"

      inspect_with_sorbet(paths, run_all: false)
    end

    sig { params(paths: T::Array[String], run_all: T::Boolean).returns(T.untyped) }
    private def inspect_with_sorbet(paths = [], run_all: false)
      runner = Runner.new(@options)
      _result, passed = runner.run(paths, run_all: run_all)

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
