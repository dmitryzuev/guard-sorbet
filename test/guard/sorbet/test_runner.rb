# typed: false
# frozen_string_literal: true

require "test_helper"

class Guard::Sorbet::TestRunner < Minitest::Spec
  let(:runner) { Guard::Sorbet::Runner.new(options) }
  let(:options) { {} }
  let(:success_status) { stub(success?: true) }
  let(:failure_status) { stub(success?: false) }

  describe "#run" do
    subject { runner.run(paths) }
    let(:paths) { ["test/test_helper.rb"] }

    it "executes sorbet" do
      Open3.expects(:capture2e).with do |*actual|
        assert_equal("srb", actual.first)
      end.returns(["", success_status])
      assert_output do
        assert(runner.run)
      end
    end

    it "returns true when Sorbet exited with 0 status" do
      Open3.expects(:capture2e).returns(["", success_status])
      assert_output do
        assert(runner.run)
      end
    end

    it "returns false when Sorbet exited with non 0 status" do
      Open3.expects(:capture2e).returns(["", failure_status])
      assert_output do
        refute(runner.run)
      end
    end

    describe "when :notification option is true" do
      let(:options) { { notification: true } }

      it "notifies when passed" do
        Open3.expects(:capture2e).returns(["", success_status])
        runner.expects(:notify).once
        assert_output do
          runner.run
        end
      end

      it "notifies when failed" do
        Open3.expects(:capture2e).returns(["", failure_status])
        runner.expects(:notify).once
        assert_output do
          runner.run
        end
      end
    end

    describe "when :notification option is :failed" do
      let(:options) { { notification: :failed } }

      it "doesn't notify when passed" do
        Open3.expects(:capture2e).returns(["", success_status])
        runner.expects(:notify).never
        assert_output do
          runner.run
        end
      end

      it "notifies when failed" do
        Open3.expects(:capture2e).returns(["", failure_status])
        runner.expects(:notify).once
        assert_output do
          runner.run
        end
      end
    end

    describe "when :notification option is false" do
      let(:options) { { notification: false } }

      it "doesn't notify when passed" do
        Open3.expects(:capture2e).returns(["", success_status])
        runner.expects(:notify).never
        assert_output do
          runner.run
        end
      end

      it "doesn't notify when failed" do
        Open3.expects(:capture2e).returns(["", failure_status])
        runner.expects(:notify).never
        assert_output do
          runner.run
        end
      end
    end
  end

  describe "#build_command" do
    let(:build_command) { runner.build_command(paths) }
    let(:options) { { cli: %w[--suppress-non-critical --force-hashing] } }
    let(:paths) { %w[file1.rb file2.rb] }

    describe ":cmd option" do
      describe "when set" do
        let(:options) { { cmd: "bin/srb" } }

        it "uses the supplied :cmd" do
          assert_equal("bin/srb", build_command[0])
        end
      end

      describe "when not set" do
        it "uses the default command" do
          assert_equal("srb", build_command[0])
        end
      end
    end

    describe "when :config is not set" do
      before { options.delete(:config) }

      it "adds --no-config" do
        assert_includes(build_command, "--no-config")
      end
    end

    describe "when :config is set" do
      before { options[:config] = true }

      it "doesn't add --no-config" do
        refute_includes(build_command, "--no-config")
      end
    end

    describe "when :colorize is not set" do
      before { options.delete(:colorize) }

      it "doesn't add --color" do
        refute_includes(build_command, "--color")
      end
    end

    describe "when :colorize is set" do
      before { options[:colorize] = "always" }

      it "adds --color" do
        assert_includes(build_command, "--color")
      end
    end

    it "adds args specified by user" do
      assert_includes(build_command, "--suppress-non-critical")
      assert_includes(build_command, "--force-hashing")
    end

    it "adds the passed paths" do
      assert_equal(%w[file1.rb file2.rb], build_command[-2..])
    end
  end
end
