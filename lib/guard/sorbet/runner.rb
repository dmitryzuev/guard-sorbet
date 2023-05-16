# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "shellwords"
require "open3"

module Guard
  class Sorbet
    class Runner
      extend T::Sig

      sig { params(options: T::Hash[Symbol, T.untyped]).void }
      def initialize(options)
        @options = options
        @args_specified_by_user = T.let(nil, T.nilable(T::Array[String]))
      end

      sig { params(paths: T::Array[String], run_all: T::Boolean).returns([String, T::Boolean]) }
      def run(paths = [], run_all: false)
        command = build_command(paths, run_all: run_all)
        result, status = T.unsafe(Open3).capture2e(*command)

        case @options[:notification]
        when :failed
          notify(result, false) unless status.success?
        when true
          notify(result, status.success?)
        end

        # $stdout.puts result unless @options[:hide_stdout]
        # warn(result)

        open_launchy_if_needed

        [result, status.success?]
      end

      sig { params(paths: T::Array[String], run_all: T::Boolean).returns(T::Array[String]) }
      def build_command(paths, run_all:)
        command = [@options[:cmd] || "srb"]
        command.push("tc")

        command.push("--no-config") unless @options[:config]
        command.push("--color", @options[:colorize]) if @options[:colorize]

        if run_all
          command.push("--dir", ".")
        else
          command.push("--dir", "sorbet")
        end

        command.concat(args_specified_by_user)
        command.concat(paths)
      end

      sig { returns(T::Array[String]) }
      def args_specified_by_user
        @args_specified_by_user ||= begin
          args = @options[:cli]
          case args
          when Array    then args
          when String   then Shellwords.split(args)
          when NilClass then []
          else raise ArgumentError, ":cli option must be either an array or string"
          end
        end
      end

      sig { params(result: String, success: T::Boolean).void }
      def notify(result, success)
        image = success ? :success : :failed
        Notifier.notify(result, title: "Sorbet results", image: image)
      end

      sig { void }
      def open_launchy_if_needed
        return unless (output_path = @options[:launchy])
        return unless File.exist?(output_path)

        begin
          require "launchy"
          ::Launchy.open(output_path)
        rescue LoadError
          nil
        end
      end
    end
  end
end
