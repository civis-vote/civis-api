# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development?
  RailsERD.load_tasks

  # TMP Fix for Rails 6.
  Rake::Task["erd:load_models"].clear

  namespace :erd do
    task :load_models do
      Rake::Task[:environment].invoke
      Zeitwerk::Loader.eager_load_all
    end
  end
end
