# frozen_string_literal: true

module FoundersTemplate
  module Utils
    def add_to_envrc(variables)
      create_file '.envrc' unless File.exist?('.envrc')

      variables.each do |name, value|
        name = name.to_s
        append_to_file '.envrc', "export #{name}=#{value}\n"
        ENV[name] = value
      end

      run 'direnv allow .'
    end

    def check_command(command)
      return true if system_command?(command)

      say_status :missing, command
      false
    end

    def system_command?(command)
      system("which #{Shellwords.escape(command)} > /dev/null 2>&1")
    end

    def template_file(template_file)
      template template_file.template_file,
               template_file.output_file,
               context: template_file.binding_for_render
    end
  end
end
