require 'phantom_jasmine/version'

module PhantomJasmine
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'tasks/phantom_jasmine.rake'
    end
  end
end
