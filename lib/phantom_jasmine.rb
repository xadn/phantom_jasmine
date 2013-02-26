require 'phantom_jasmine/version'
require 'jasmine/runners/phantom'

module PhantomJasmine
  begin
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'tasks/phantom_jasmine.rake'
      end
    end
  rescue LoadError, NameError
  end
end
