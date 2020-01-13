guard :rspec,
      cmd: "bin/rspec",
      all_on_start: true,
      all_after_pass: false,
      failed_mode: :keep do

  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w(erb haml slim))
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.controllers) do |m|
    [
      rspec.spec.call("controllers/#{m[1]}_controller"),
      rspec.spec.call("system/#{m[1]}"),
      rspec.spec.call("requests/#{m[1]}"),
    ]
  end

  # Rails config changes
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }
end
