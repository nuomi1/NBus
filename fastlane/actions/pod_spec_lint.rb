module Fastlane
  module Actions
    class PodSpecLintAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      def self.run(params)
        command = []

        command << "bundle exec" if params[:use_bundle_exec] && shell_out_should_use_bundle_exec?
        command << "pod spec lint"

        command << params[:podspec] if params[:podspec]
        command << "--verbose" if params[:verbose]
        command << "--quick" if params[:quick]
        command << "--allow-warnings" if params[:allow_warnings]
        command << "--subspec=#{params[:subspec]}" if params[:subspec]
        command << "--no-subspecs" if params[:no_subspecs]
        command << "--no-clean" if params[:no_clean]
        command << "--fail-fast" if params[:fail_fast]
        command << "--use-libraries" if params[:use_libraries]
        command << "--use-modular-headers" if params[:use_modular_headers]
        command << "--use-static-frameworks" if params[:use_static_frameworks]
        command << "--sources='#{params[:sources].join(",")}'" if params[:sources]
        command << "--platforms=#{params[:platforms]}" if params[:platforms]
        command << "--private" if params[:private]
        command << "--swift-version=#{params[:swift_version]}" if params[:swift_version]
        command << "--skip-import-validation" if params[:skip_import_validation]
        command << "--skip-tests" if params[:skip_tests]
        command << "--test-specs=#{params[:test_specs]}" if params[:test_specs]
        command << "--analyze" if params[:analyze]
        command << "--configuration=#{params[:configuration]}" if params[:configuration]

        result = Actions.sh(command.join(" "))
        UI.success("Pod spec lint Successfully ⬆️ ")
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Pod spec lint"
      end

      def self.details
        "Validates `NAME.podspec`. If a `DIRECTORY` is provided, it validates the podspec files found, including subfolders. In case the argument is omitted, it defaults to the current working dir."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                       env_name: "FL_POD_SPEC_LINT_USE_BUNDLE",
                                       description: "Use bundle exec when there is a Gemfile presented",
                                       default_value: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :podspec,
                                       env_name: "FL_POD_SPEC_LINT_PODSPEC",
                                       description: "Path of spec to lint",
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_POD_SPEC_LINT_VERBOSE",
                                       description: "Show more debugging information",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :quick,
                                       env_name: "FL_POD_SPEC_LINT_QUICK",
                                       description: "Lint skips checks that would require to download and build the spec",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                       env_name: "FL_POD_SPEC_LINT_ALLOW_WARNINGS",
                                       description: "Lint validates even if warnings are present",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :subspec,
                                       env_name: "FL_POD_SPEC_LINT_SUBSPEC",
                                       description: "Lint validates only the given subspec",
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :no_subspecs,
                                       env_name: "FL_POD_SPEC_LINT_NO_SUBSPECS",
                                       description: "Lint skips validation of subspecs",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :no_clean,
                                       env_name: "FL_POD_SPEC_LINT_NO_CLEAN",
                                       description: "Lint leaves the build directory intact for inspection",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :fail_fast,
                                       env_name: "FL_POD_SPEC_LINT_FAIL_FAST",
                                       description: "Lint stops on the first failing platform or subspec",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :use_libraries,
                                       env_name: "FL_POD_SPEC_LINT_USE_LIBRARIES",
                                       description: "Lint uses static libraries to install the spec",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :use_modular_headers,
                                       env_name: "FL_POD_SPEC_LINT_USE_MODULAR_HEADERS",
                                       description: "Lint uses modular headers during installation",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :use_static_frameworks,
                                       env_name: "FL_POD_SPEC_LINT_USE_STATIC_FRAMEWORKS",
                                       description: "Lint uses static frameworks during installation",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :sources,
                                       env_name: "FL_POD_SPEC_LINT_SOURCES",
                                       description: "The sources from which to pull dependent pods",
                                       verify_block: proc do |value|
                                         UI.user_error!("Sources must be an array.") unless value.kind_of?(Array)
                                       end,
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :platforms,
                                       env_name: "FL_POD_SPEC_LINT_PLATFORMS",
                                       description: "Lint against specific platforms",
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :private,
                                       env_name: "FL_POD_SPEC_LINT_PRIVATE",
                                       description: "Lint skips checks that apply only to public specs",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :swift_version,
                                       env_name: "FL_POD_SPEC_LINT_SWIFT_VERSION",
                                       description: "The `SWIFT_VERSION` that should be used to lint the spec. This takes precedence over the Swift versions specified by the spec or a `.swift-version` file",
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :skip_import_validation,
                                       env_name: "FL_POD_SPEC_LINT_SKIP_IMPORT_VALIDATION",
                                       description: "Lint skips validating that the pod can be imported",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :skip_tests,
                                       env_name: "FL_POD_SPEC_LINT_SKIP_TESTS",
                                       description: "Lint skips building and running tests during validation",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :test_specs,
                                       env_name: "FL_POD_SPEC_LINT_TEST_SPECS",
                                       description: "List of test specs to run",
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :analyze,
                                       env_name: "FL_POD_SPEC_LINT_ANALYZE",
                                       description: "Validate with the Xcode Static Analysis tool",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "FL_POD_SPEC_LINT_CONFIGURATION",
                                       description: "Build using the given configuration",
                                       type: String,
                                       optional: true),
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["nuomi1"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          "pod_spec_lint",
          "# Allow output detail in console
          pod_spec_lint(verbose: true)",
          "# Allow warnings during pod lint
          pod_spec_lint(allow_warnings: true)",
          '# If the podspec has a dependency on another private pod, then you will have to supply the sources
          pod_spec_lint(sources: ["https://github.com/username/Specs", "https://github.com/CocoaPods/Specs"])',
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
