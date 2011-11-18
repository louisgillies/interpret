unless Interpret.isolate_namespace
  Rails.application.routes.draw do
    namespace :interpret do
      scope ":locale" do
        resources :translations, :only => [:destroy, :edit, :update, :create, :index] do
          collection do
            get :live_edit
          end
        end

        resources :tools, :only => :index do
          collection do
            get :export
            post :import
            post :dump
            post :run_update
          end
        end

        match "search", :to => "search#index", :as => "translations_search"
        resources :missing_translations
        match "blank", :to => "missing_translations#blank", :as => "blank_translations"
        match "unused", :to => "missing_translations#unused", :as => "unused_translations"
        match "stale", :to => "missing_translations#stale", :as => "stale_translations"
      end
    end
  end
end

