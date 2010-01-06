Gem::Specification.new do |s|
  s.name        = "web_translate_it" 
  s.version     = "1.3.0"
  s.summary     = "Sync your translations between your Rails app and Web Translate It"
  s.email       = "edouard@atelierconvivialite.com"
  s.homepage    = "https://webtranslateit.com"
  s.description = "Ruby on Rails plugin and rack middleware to sync your translations between webtranslateit.com and your rails applications."
  s.authors     = ["Édouard Brière"]
 
  s.files =  ["history.md", "MIT-LICENSE", "README.md"]
  s.files += ["examples/locale.rb"]
  s.files += ["lib/web_translate_it.rb", "lib/web_translate_it/auto_fetch.rb", "lib/web_translate_it/configuration.rb", "lib/web_translate_it/translation_file.rb", "lib/web_translate_it/util.rb"]
  s.files += ["tasks/rails.rake", "tasks/translation_example.yml"]
  
  s.test_files = ["spec/configuration_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/translation_file_spec.rb", "spec/examples/en.yml", "spec/examples/translation.yml"]  
  
  s.add_dependency("multipart-post", ["~> 1.0"])
  
  s.has_rdoc = false
  # s.rdoc_options = ["--main", "README"]
  # s.extra_rdoc_files = ["HISTORY", "Manifest.txt", "README"]
end
