# frozen_string_literal: true

module FoundersTemplate
  class TemplateFile
    def self.root_key(key = nil)
      @root_key = key if key
      @root_key ||= nil
    end

    def self.output_file(file_name = nil)
      @output_file = file_name if file_name
      @output_file ||= nil
    end

    def self.template_file(file_name = nil)
      @template_file = file_name if file_name
      @template_file ||= nil
    end

    def self.required_keys(keys = nil)
      @required_keys = keys if keys
      @required_keys ||= []
    end

    def initialize(output_directory)
      @output_directory = output_directory
      @data = File.exist?(output_file) && YAML.load_file(output_file)
      return unless @data

      @data = @data[self.class.root_key] if self.class.root_key
      @data.symbolize_keys!
      load_data
    end

    def valid?
      self.class.required_keys.none? { |key| public_send(key).nil? }
    end

    def binding_for_render
      binding
    end

    def template_file
      self.class.template_file
    end

    def output_file
      File.join(@output_directory, self.class.output_file)
    end

    private

    def load_data
      @data.each do |key, value|
        public_send("#{key}=", value)
      end
    end
  end
end
