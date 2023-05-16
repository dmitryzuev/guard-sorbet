# typed: false
# frozen_string_literal: true

require "test_helper"

class Guard::TestSrb < Minitest::Spec
  let(:options) { {} }
  subject { Guard::Srb.new(options) }

  describe "#options" do
    describe "by default" do
      it "has default options" do
        options = subject.options

        assert_equal(true, options[:all_on_start])
        assert_equal(:failed, options[:notification])
        assert_equal(false, options[:hide_stdout])
        assert_equal("always", options[:colorize])
        assert_nil(options[:cmd])
        assert_nil(options[:cli])
        assert_nil(options[:config])
      end
    end
  end

  describe "#start" do
    describe "when :all_on_start option is enabled" do
      let(:options) { { all_on_start: true } }

      it "runs all" do
        subject.expects(:run_all).once
        subject.start
      end
    end

    describe "when :all_on_start option is disabled" do
      let(:options) { { all_on_start: false } }

      it "does nothing" do
        subject.expects(:run_all).never
        subject.start
      end
    end
  end

  describe "#run_all" do
    subject { Guard::Srb.new(options).run_all }

    it "inspects all files with rubocop" do
      Guard::Srb::Runner.any_instance.expects(:run).with([]).returns(true)

      assert_output do
        subject
      end
    end

    describe "when passed" do
      it "throws nothing" do
        Guard::Srb::Runner.any_instance.expects(:run).returns(true)
        assert_output do
          subject
        end
      end
    end

    describe "when failed" do
      it "throws symbol :task_has_failed" do
        Guard::Srb::Runner.any_instance.expects(:run).returns(false)
        assert_throws(:task_has_failed) do
          assert_output do
            subject
          end
        end
      end
    end

    describe "when an exception is raised" do
      it "prevents itself from firing" do
        Guard::Srb::Runner.any_instance.expects(:run).raises(RuntimeError)
        assert_output do
          subject
        end
      end
    end
  end

  %i[run_on_additions run_on_modifications].each do |method|
    describe "##{method}" do
      let(:changed_paths) do
        [
          "lib/guard/srb.rb",
          "test/test_helper.rb"
        ]
      end
      subject { Guard::Srb.new(options).send(method, changed_paths) }

      describe "when passed" do
        it "throws nothing" do
          Guard::Srb::Runner.any_instance.expects(:run).returns(true)
          assert_output do
            subject
          end
        end
      end

      describe "when failed" do
        it "throws symbol :task_has_failed" do
          Guard::Srb::Runner.any_instance.expects(:run).returns(false)
          assert_throws(:task_has_failed) do
            assert_output do
              subject
            end
          end
        end
      end

      describe "when an exception is raised" do
        it "prevents itself from firing" do
          Guard::Srb::Runner.any_instance.expects(:run).raises(RuntimeError)
          assert_output do
            subject
          end
        end
      end

      it "inspects changed files with sorbet" do
        Guard::Srb::Runner.any_instance.expects(:run)
        assert_output do
          subject
        end
      end

      it "passes cleaned paths to sorbet" do
        Guard::Srb::Runner.any_instance.expects(:run).with do |actual|
          paths = changed_paths.map { |f| File.expand_path(f) }
          assert_equal(paths, actual)
        end

        assert_output do
          subject
        end
      end

      describe "when cleaned paths are empty" do
        it "does nothing" do
          Guard::Srb.any_instance.stubs(:clean_paths).returns([])
          Guard::Srb::Runner.any_instance.expects(:run).never

          assert_output do
            subject
          end
        end
      end
    end
  end

  describe "#clean_paths" do
    def clean_paths(path)
      subject.send(:clean_paths, path)
    end

    it "converts to absolute paths" do
      paths = [
        "lib/guard/srb.rb",
        "test/test_helper.rb"
      ]
      expanded_paths = paths.map { |f| File.expand_path(f) }
      assert_equal(expanded_paths, clean_paths(paths))
    end

    it "removes duplicated paths" do
      paths = [
        "lib/guard/srb.rb",
        "test/test_helper.rb",
        "lib/guard/../guard/srb.rb"
      ]
      clean = [
        File.expand_path("lib/guard/srb.rb"),
        File.expand_path("test/test_helper.rb")
      ]
      assert_equal(clean, clean_paths(paths))
    end

    it "removes non-existent paths" do
      paths = [
        "lib/guard/srb.rb",
        "path/to/non_existent_file.rb",
        "test/test_helper.rb"
      ]
      clean = [
        File.expand_path("lib/guard/srb.rb"),
        File.expand_path("test/test_helper.rb")
      ]
      assert_equal(clean, clean_paths(paths))
    end

    it "removes paths which are included in another path" do
      paths = [
        "lib/guard/srb.rb",
        "test/test_helper.rb",
        "test"
      ]
      clean = [
        File.expand_path("lib/guard/srb.rb"),
        File.expand_path("test")
      ]
      assert_equal(clean, clean_paths(paths))
    end
  end

  describe "#smart_path" do
    def smart_path(path)
      subject.send(:smart_path, path)
    end

    describe "when the passed path is under the current working directory" do
      let(:path) { File.expand_path("test/test_helper.rb") }

      it "returns relative path" do
        assert_equal("test/test_helper.rb", smart_path(path))
      end
    end

    describe "when the passed path is outside of the current working directory" do
      let(:path) do
        tempfile = Tempfile.new("")
        tempfile.close
        File.expand_path(tempfile.path)
      end

      it "returns absolute path" do
        assert_equal(path, smart_path(path))
      end
    end
  end
end
