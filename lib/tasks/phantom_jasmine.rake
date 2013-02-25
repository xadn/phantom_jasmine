namespace :jasmine do
  desc "Run continuous integration tests with phantom"
  task :phantom => ["jasmine:require_json", "jasmine:require"] do
    if Jasmine::Dependencies.rspec2?
      require "rspec"
      require "rspec/core/rake_task"
    else
      require "spec"
      require 'spec/rake/spectask'
    end

    run_specs = ["#{File.join(File.dirname(__FILE__), '..', 'phantom_jasmine', 'run_specs.rb')}"]
    if Jasmine::Dependencies.rspec2?
      RSpec::Core::RakeTask.new(:jasmine_continuous_integration_runner) do |t|
        t.rspec_opts = ["--colour", "--format", ENV['JASMINE_SPEC_FORMAT'] || "progress"]
        t.verbose = true
        if Jasmine::Dependencies.rails_3_asset_pipeline?
          t.rspec_opts += ["-r #{File.expand_path(File.join(::Rails.root, 'config', 'environment'))}"]
        end
        t.pattern = run_specs
      end
    else
      Spec::Rake::SpecTask.new(:jasmine_continuous_integration_runner) do |t|
        t.spec_opts = ["--color", "--format", ENV['JASMINE_SPEC_FORMAT'] || "specdoc"]
        t.verbose = true
        t.spec_files = run_specs
      end
    end
    Rake::Task["jasmine_continuous_integration_runner"].invoke
  end
end
