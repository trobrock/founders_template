# frozen_string_literal: true

require 'founders_template/template_file'
require 'active_support/core_ext/string/inflections'

module FoundersTemplate
  class ConfigFile < TemplateFile
    root_key 'application'
    required_keys %i( name short_name github_org github_repo)

    template_file 'ft.yml.erb'
    output_file 'ft.yml'

    attr_accessor :name, :github_org, :github_repo
    attr_writer :short_name

    def short_name
      @short_name ||= name.split.map(&:chr).join.downcase
    end

    def slugified_name
      name.parameterize
    end

    def aws_region
      ENV['AWS_REGION']
    end
  end
end
