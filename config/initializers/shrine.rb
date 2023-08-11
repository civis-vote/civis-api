require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/s3"

test_secret_key = "036b0c1d57dc1e57e369c1441ae13c44231dad82df902a03420456b8c0ec3e3b5d1c53ff27fa6651307f13bda811cd5e0c4227c07fa906e499ad967bbd0a019f"
# loads Active Record integration
Shrine.plugin :activerecord
# enables retaining cached file across form redisplays
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :remote_url, max_size: nil
Shrine.plugin :derivation_endpoint, secret_key: Rails.env.test? ? test_secret_key : Rails.application.credentials.dig(:secret_key_base)

def production_storages
  s3_options = Rails.application.credentials.dig(:aws)

  Shrine.plugin :url_options, store: { host: "https://production.cdn.civis.vote/" }

  {
    cache: Shrine::Storage::FileSystem.new(Rails.root.join("public"), prefix: "uploads/cache"),
    store: Shrine::Storage::S3.new(prefix: "uploads", upload_options: { acl: "public-read" }, **s3_options),
  }
end

def staging_storages
  s3_options = Rails.application.credentials.dig(:aws)

  Shrine.plugin :url_options, store: { host: "https://staging.cdn.civis.vote/" }

  {
    cache: Shrine::Storage::FileSystem.new(Rails.root.join("public"), prefix: "uploads/cache"),
    store: Shrine::Storage::S3.new(prefix: "uploads", upload_options: { acl: "public-read" }, **s3_options),
  }
end

def development_storages
  {
    # temporary
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    # permanent
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),
  }
end

Shrine.storages = Shrine.send(ENV["shrine_storages"]) if ENV["shrine_storages"].present?
Shrine.storages = development_storages if Rails.env.development?