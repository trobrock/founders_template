# frozen_string_literal: true

require 'shellwords'
require 'thor'

SCRIPT_PATH = File.expand_path(File.join(__dir__, '..', '..', 'bash')).freeze

module FoundersTemplate
  class CLI < Thor
    include Thor::Actions

    desc 'ci SCRIPT_NAME', 'exec the ci script SCRIPT_NAME'
    def ci(script_name, *args)
      script_name = Shellwords.escape(script_name)
      file_path = File.join(SCRIPT_PATH, 'ci', "#{script_name}.sh")

      exec '/usr/bin/env', 'bash', file_path, *args
    end

    def self.source_root
      File.join(__dir__, '../../templates')
    end

    desc 'install', 'install the buildspec'
    def install
      template 'buildspec.yml.erb', 'buildspec.yml'

      directory 'ci', 'ci'
    end
  end
end
