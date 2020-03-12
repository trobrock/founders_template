# frozen_string_literal: true

require_relative 'lib/founders_template/version'

Gem::Specification.new do |spec|
  spec.name          = 'founders_template'
  spec.version       = FoundersTemplate::VERSION
  spec.authors       = ['Trae Robrock']
  spec.email         = ['trobrock@gmail.com']

  spec.summary       = "The command line tool used to manage the Founder's Template"
  spec.description   = "The command line tool used to manage the Founder's Template"
  spec.homepage      = 'https://github.com/trobrock/founders_template'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/trobrock/founders_template.git'
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 1.0'
end
