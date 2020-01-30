require 'aws-sdk-s3'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.civis.vote/"
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create(include_root: true, include_index: true) do
  group(sitemaps_path: "sitemaps/", :filename => "consultations", compress: true) do
    Consultation.where(status: [:published, :expired]).find_each do |consultation|
      add "/consultations/#{consultation.id}/read", priority: 0.9
    end
  end
end

SitemapGenerator::Sitemap.create(include_index: false, filename: "sitemap", compress: true) do
  group(include_root: true, sitemaps_path: "sitemaps/", filename: "sitemap-static") do
    add "/consultations/list"
    add "/leader-board"
    add "/how-civis-works"
    add "/consultations/new"
    add "/about-us"
    add "/terms"
    add "/privacy"
    add "/content-policy"
  end
  add_to_index '/sitemaps/consultations.xml.gz'
end

#uploading to aws-cloud-storage
aws_client = Aws::S3::Client.new(
  access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
  secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
  region: "eu-west-1"
)
s3 = Aws::S3::Resource.new(client: aws_client)

#uploading sitemap.xml.gz
file_name = "#{Rails.root}/public/sitemaps/sitemap.xml.gz"
bucket_name = "civis-sitemaps-#{Rails.env}"
obj = s3.bucket(bucket_name).object("sitemap.xml.gz")
obj.upload_file(file_name, { acl: 'public-read', content_type: 'application/x-gzip' })

#uploading sitemap-static.xml.gz
file_name = "#{Rails.root}/public/sitemaps/sitemap-static.xml.gz"
obj = s3.bucket(bucket_name).object("sitemap-static.xml.gz")
obj.upload_file(file_name, { acl: 'public-read', content_type: 'application/x-gzip' })

#uploading sitemap-static.xml.gz
file_name = "#{Rails.root}/public/sitemaps/consultations.xml.gz"
obj = s3.bucket(bucket_name).object("consultations.xml.gz")
obj.upload_file(file_name, { acl: 'public-read', content_type: 'application/x-gzip' })