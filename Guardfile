require 'rake'
::Rake.application.init
::Rake.application.load_rakefile

# Run `bundle install` whenever Gemfile changes.
guard :bundler do
  watch('Gemfile')
end

# Run local solr on launch and whenever sunspot config changes.
%w(development test).each do |env|
  guard 'sunspot', environment: env do
    # watch('Gemfile.lock') # gems don't usually affect sunspot, so be careful to check this manually
    watch('config/sunspot.yml')
  end
end

# Reloads spring whenever configs change.
guard 'spring', bundler: true, environments: %w(development) do
  watch('Gemfile.lock')
  watch(%r{^config/})
end

# Restart the dev server whenever configs change. (The dev server will automatically reload app code.)
guard :rails, port: 8000, host: '0.0.0.0', server: :puma do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
  ignore %r{^lib/locales/(.*)\.yml}
end

# Rerun tests whenever test or app code changes.
guard :minitest, spring: 'bin/rails test', env: {CAPYBARA_SKIP_JS: 'true'} do
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }

  watch(%r{^app/(.+)\.rb$}) { 'test' }# run all tests on app code change (for now)
  # watch(%r{^app/controllers/application_controller\.rb$}) { 'test/controllers' }
  # watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| "test/integration/#{m[1]}_test.rb" }
  # watch(%r{^app/views/(.+)_mailer/.+})                    { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
  # watch(%r{^lib/(.+)\.rb$})                               { |m| "test/lib/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/fixtures/.+\.yml$})
  watch(%r{^test/test_helper\.rb$}) { 'test' }
end

# Run a webpack watcher
webpack_dev_pid = nil
start_webpack_dev = Proc.new do
  webpack_dev_pid = fork do
    system 'bin/webpack-dev-server'
  end
end
stop_webpack_dev = Proc.new do
  webpack_dev_pid.try :kill
  webpack_dev_pid = nil
end
restart_webpack_dev = Proc.new do
  stop_webpack_dev
  start_webpack_dev
end
guard :yield, start: start_webpack_dev, stop: stop_webpack_dev, run_on_changes: restart_webpack_dev do
  watch(%r{^config/webpack/(.*)$})
end
