Paperclip::Attachment.default_options[:storage] = Chamber.env.attachment.storage

if Chamber.env.attachment.storage == 's3'
  s3_config = { s3_credentials: { bucket: Chamber.env.attachment.s3_bucket }, s3_permissions: { original: :private } }
  Paperclip::Attachment.default_options.merge!(s3_config)
end

