# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# tell Rack (and Sprockets) about modern font MIME types:
Rack::Mime::MIME_TYPES['.woff'] = 'application/x-font-woff'
Rack::Mime::MIME_TYPES['.ttf'] = 'application/x-font-ttf'
Rack::Mime::MIME_TYPES['.eot'] = 'application/vnd.ms-fontobject'
Rack::Mime::MIME_TYPES['.svg'] = 'image/svg+xml'
Mime::Type.register 'application/x-font-woff', :woff
Mime::Type.register 'application/x-font-ttf', :ttf
Mime::Type.register 'application/vnd.ms-fontobject', :eot
Mime::Type.register 'image/svg+xml', :svg

# ActionController:Live uses text/event-stream for SSE
Mime::Type.register "text/event-stream", :stream