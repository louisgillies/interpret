require 'interpret/logger'
require 'interpret/helpers'

module Interpret
  class Engine < Rails::Engine

    initializer "interpret.register_i18n_active_record_backend" do |app|
      app.config.after_initialize do
        if Interpret.registered_envs.include?(Rails.env.to_sym)
          I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
          I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)

          Interpret.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)
          I18n.backend = Interpret.backend
        end
      end
    end

    initializer "interpret.setup_translations_logger" do |app|
      logfile = File.open("#{Rails.root}/log/interpret.log", 'a')
      logfile.sync = true
      Interpret.logger = InterpretLogger.new(logfile)
    end

    initializer "interpret.isolate" do |app|
      app.config.after_initialize do
        isolate_namespace Interpret if Interpret.isolate_namespace
      end
    end
    
    initializer "interpret.locale_files" do |app|
      app.config.after_initialize do
        Interpret.load_path = I18n.load_path if Interpret.load_path.nil?
      end
    end
    
    initializer "interpret.register_observer" do |app|
      #app.config.before_initialize do |app|
        require 'active_record'
        require 'i18n/backend/active_record'
        ActiveRecord::Base.observers << Interpret.sweeper.to_sym if Interpret.sweeper && I18n::Backend::ActiveRecord::Translation.table_exists?
        ActiveRecord::Base.observers << :"interpret/expiration_observer" if !Interpret.sweeper && I18n::Backend::ActiveRecord::Translation.table_exists?
      #end
    end
  end
end
