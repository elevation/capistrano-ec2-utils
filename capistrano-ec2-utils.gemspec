require 'English'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'capistrano-ec2-utils'
  s.version       = File.read('VERSION').strip
  s.summary       = 'Capistrano EC2 Utilities'
  s.description   = 'Capistrano plugin providing some useful utilities for \
                     interacting with EC2'

  s.authors       = ['Jared Moody']
  s.email         = ['jared@yourelevation.com']
  s.homepage      = 'https://github.com/elevation/capistrano-ec2-utils'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = ['lib']

  s.add_dependency 'capistrano', '~> 3.1'
  s.add_dependency 'aws-sdk'
end
