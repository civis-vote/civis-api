require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/s3"


Shrine.plugin :activerecord           # loads Active Record integration
Shrine.plugin :cached_attachment_data # enables retaining cached file across form redisplays
Shrine.plugin :restore_cached_data
Shrine.plugin :remote_url, max_size: nil

def production_storages
  s3_options = {
    access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
    secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
    bucket: 'civis-api-production',
    region: 'eu-west-1'
  }

  Shrine.plugin :url_options, store: { host: "https://cdn.civis.vote/" }

  {
    store: Shrine::Storage::S3.new(prefix: 'uploads', upload_options: { acl: 'public-read' }, **s3_options)
  }
end

def staging_storages
  s3_options = {
    access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
    secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
    bucket: 'civis-api-staging',
    region: 'eu-west-1'
  }

  Shrine.plugin :url_options, store: { host: "https://cdn-staging.civis.vote/" }

  {
    store: Shrine::Storage::S3.new(prefix: 'uploads', upload_options: { acl: 'public-read' }, **s3_options)
  }
end

def development_storages
  {
    store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads'), # permanent
  }
end

if Rails.env.production?
  Shrine.storages = production_storages
elsif Rails.env.staging?
  Shrine.storages = staging_storages
else
  Shrine.storages = development_storages
end