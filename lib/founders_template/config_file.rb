# frozen_string_literal: true

require 'founders_template/template_file'

module FoundersTemplate
  class ConfigFile < TemplateFile
    root_key 'application'
    required_keys %i( name short_name )

    template_file 'ft.yml.erb'
    output_file 'ft.yml'

    attr_accessor :name
    attr_writer :short_name

    def short_name
      @short_name ||= name.split.map(&:chr).join.downcase
    end
  end
end
