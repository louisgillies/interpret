require 'i18n/backend/active_record'
require 'interpret/logger'
require 'interpret/helpers'

module Interpret
  class Engine < Rails::Engine
    if Interpret.registered_envs.include?(Rails.env.to_sym)
      initializer "interpret.register_i18n_active_record_backend" do |app|
        I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
        I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)

        Interpret.backend = I18n::Backend::ActiveRecord.new
        app.config.i18n.backend = Interpret.backend
      end
    end

    initializer "interpret.setup_translations_logger" do |app|
      logfile = File.open("#{Rails.root}/log/interpret.log", 'a')
      logfile.sync = true
      Interpret.logger = InterpretLogger.new(logfile)
    end


    initializer "interpret.register_observer" do |app|
      app.config.after_initialize do
        ActiveRecord::Base.observers << Interpret.sweeper.to_sym if Interpret.sweeper
      end
    end
  end
end
