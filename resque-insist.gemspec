$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "resque-insist"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jordi Romero"]
  s.email       = ["jordi@jrom.net"]
  s.homepage    = "http://github.com/jrom/resque-insist"
  s.summary     = %q{Give your Resque jobs a second chance}
  s.description = %q{If you want to give your jobs a second change (or more) extend them with this plugin and let the job fail some times before considering it failed.}

  s.files         = `git ls-files`.split("\n") - %w(.gitignore .rspec) - ['autotest/discover.rb']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "resque", "~> 1.10.0"
  s.add_development_dependency "rspec", "~> 2.2.0"

end
