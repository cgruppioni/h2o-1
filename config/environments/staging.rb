require Rails.root.join("config/environments/production")

H2o::Application.configure do
  # log settings
  config.log_level = :debug

  # allow users without verified .edu addresses
  config.disable_verification = true

  # cap api settings
  config.admin_email = ['cgruppioni@law.harvard.edu']
  config.professor_verifier_email = "cgruppioni@law.harvard.edu"

  config.ssr_export_feature_flag = ENV['SSR_EXPORT_FEATURE_FLAG']
end
