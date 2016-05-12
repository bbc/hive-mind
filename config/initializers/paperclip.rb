Paperclip::Attachment.default_options[:storage] = ENV['ATTACHMENT_STORAGE']

if Chamber.env.attachment.storage == 's3'
  s3_config = { s3_credentials: { bucket: ENV['ATTACHMENT_S3_BUCKET'] }, s3_permissions: { original: :private } }
  Paperclip::Attachment.default_options.merge!(s3_config)
end

