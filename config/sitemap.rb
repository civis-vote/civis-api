require "google/cloud/storage"

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

SitemapGenerator::Sitemap.create(include_index: false) do
  add "sitemaps/consultations.xml.gz"
  add "/consultations/list"
  add "/leader-board"
  add "/how-civis-works"
  add "/consultations/new"
  add "/consultations/new"
  add "/about-us"
  add "/terms"
  add "/privacy"
  add "/content-policy"
  add "/content-policy"
end

#uploading to google-cloud-storage
sitemap_file_path = "#{Rails.root}/public/sitemaps/sitemap.xml.gz"
consultations_file_path = "#{Rails.root}/public/sitemaps/consultations.xml.gz"
storage = storage = Google::Cloud::Storage.new(
            project_id: Rails.application.credentials.gcs[:project_id],
            credentials: Rails.application.credentials.gcs
          )
bucket = storage.bucket("civis-api-#{Rails.env}")
bucket.file("sitemaps/sitemap.xml.gz").delete if bucket.file("sitemaps/sitemap.xml.gz")
bucket.file("sitemaps/consultations.xml.gz").delete if bucket.file("sitemaps/consultations.xml.gz")
bucket.create_file sitemap_file_path, "sitemaps/sitemap.xml.gz", acl: "public"
bucket.create_file consultations_file_path, "sitemaps/consultations.xml.gz", acl: "public"