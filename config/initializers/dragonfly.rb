Dragonfly.app.configure do
  plugin :imagemagick

  datastore :file,
    :server_root => 'public',
    :root_path => 'public/images'
end