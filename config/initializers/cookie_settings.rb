Rails.application.configure do
  # Allow cookies to be used in non-SSL environment
  config.action_dispatch.cookies_same_site_protection = :lax

  # In production, you would typically want these settings:
  # config.action_dispatch.cookies_same_site_protection = :strict
  # config.action_dispatch.cookies_secure = true

  # But for local development without SSL:
  config.action_dispatch.cookies_secure = false if Rails.env.production? && ENV["LOCAL_DEV"] == "true"
end
