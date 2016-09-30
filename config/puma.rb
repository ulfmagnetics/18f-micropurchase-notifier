# See https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#adding-puma-to-your-application
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RACK_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      'config.ru'
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
