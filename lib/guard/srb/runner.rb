# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "shellwords"
require "open3"

module Guard
  class Srb
    class Runner
      extend T::Sig

      sig { params(options: T::Hash[Symbol, T.untyped]).void }
      def initialize(options)
        @options = options
        @args_specified_by_user = T.let(nil, T.nilable(T::Array[String]))
      end

      sig { params(paths: T::Array[String]).returns(T::Boolean) }
      def run(paths = [])
        command = build_command(paths)
        result, status = T.unsafe(Open3).capture2e(*command)

        case @options[:notification]
        when :failed
          notify(result, false) unless status.success?
        when true
          notify(result, status.success?)
        end

        warn(result) unless @options[:hide_stdout]

        status.success?
      end

      sig { params(paths: T::Array[String]).returns(T::Array[String]) }
      def build_command(paths)
        command = [@options[:cmd] || "srb"]
        command.push("tc")

        command.push("--no-config") unless @options[:config]
        command.push("--color", @options[:colorize]) if @options[:colorize]
        command.push("--dir", ".")

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
        message = result.split("\n")[-1]
        image = success ? :success : :failed
        Notifier.notify(message, title: "Sorbet results", image: image)
      end
    end
  end
end
