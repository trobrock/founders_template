# frozen_string_literal: true

require 'shellwords'
require 'thor'
require 'active_support/encrypted_file'
require 'active_support/core_ext/hash/keys'
require 'aws-sdk-ec2'
require 'aws-sdk-secretsmanager'
require 'yaml'

require 'founders_template/utils'
require 'founders_template/config_file'

REQUIRED_SYSTEM_TOOLS = %w( direnv ).freeze
SCRIPT_PATH = File.expand_path(File.join(__dir__, '..', '..', 'bash')).freeze
CREDENTIALS_PATH = 'config/credentials'
CREDENTIALS_KEY_FILE = File.join(CREDENTIALS_PATH, 'production.key').freeze
CONFIG_PATH = 'config'

module FoundersTemplate
  class CLI < Thor
    include Thor::Actions
    source_root File.join(__dir__, '../../templates')

    include Utils

    desc 'ci SCRIPT_NAME', 'exec the ci script SCRIPT_NAME'
    def ci(script_name, *args)
      script_name = Shellwords.escape(script_name)
      file_path = File.join(SCRIPT_PATH, 'ci', "#{script_name}.sh")

      exec '/usr/bin/env', 'bash', file_path, *args
    end

    desc 'check', 'check that all the required tooling is installed'
    def check
      return if REQUIRED_SYSTEM_TOOLS.all? { |command| check_command(command) }

      error 'Some dependencies were missing, please check the README for instructions.'
      exit 1
    end

    desc 'install', 'install the buildspec'
    def install
      check

      ensure_application_config
      ensure_aws_credentials
      ensure_credentials_key
      ensure_secret_key

      template 'buildspec.yml.erb', 'buildspec.yml'
      template 'dockerignore.erb', '.dockerignore'
      template 'docker-compose.ci.yml.erb', 'docker-compose.ci.yml'
      template 'docker-compose.yml.erb', 'docker-compose.yml'
      template 'docker-sync.yml.erb', 'docker-sync.yml'
      template 'Dockerfile.erb', 'Dockerfile'

      install_terraform_project

      directory 'docker', 'docker'
      directory 'ci', 'ci'
    end

    private

    def version
      VERSION
    end

    def install_terraform_project
      directory 'terraform', 'terraform'

      template 'terraform-production-backend.tf.erb', 'terraform/production/backend.tf'
      template 'terraform-production.tfvars.erb', 'terraform/production/terraform.tfvars'
      template 'terraform-shared.tfvars.erb', 'terraform/shared/terraform.tfvars'
    end

    def ensure_aws_credentials
      return if aws_credentials?

      message = <<~TEXT

        We need to setup an AWS credentials profile on your system.
        This will add a section to ~/.aws/credentials so you will have a profile containing
        your keys for this project. This will then configure direnv so that whenever you are
        inside your project's directory all AWS commands will be configured to use that
        profile.

      TEXT
      say message, :yellow

      aws_access_key_id = ask 'AWS Access Key ID:'
      aws_secret_access_key = ask 'AWS Secret Access Key (typing will be hidden):', echo: false

      regions = Aws::EC2::Client.new(region: 'us-east-1',
                                     access_key_id: aws_access_key_id,
                                     secret_access_key: aws_secret_access_key).describe_regions
      aws_region = ask 'AWS Region:',
                       limited_to: regions.regions.map(&:region_name),
                       default: 'us-east-1'

      add_to_envrc AWS_REGION: aws_region
      add_to_envrc AWS_DEFAULT_REGION: aws_region

      profile = <<~TEXT
        [#{app_config.short_name}]
        aws_access_key_id = #{aws_access_key_id}
        aws_secret_access_key = #{aws_secret_access_key}
      TEXT
      append_to_file '~/.aws/credentials', profile
      add_to_envrc AWS_PROFILE: app_config.short_name
    end

    def secrets_manager_key_exist?(key_id)
      secrets_manager.describe_secret({ secret_id: key_id })
      true
    rescue Aws::SecretsManager::Errors::ResourceNotFoundException
      false
    end

    def secrets_manager_credentials_key_id
      "#{app_config.short_name}/rails/production/credentials_master_key"
    end

    def secrets_manager_secret_key_id
      "#{app_config.short_name}/rails/production/secret_key_base"
    end

    def ensure_credentials_key
      return unless credentials_supported?
      return if secrets_manager_key_exist?(secrets_manager_credentials_key_id)

      ensure_credentials_key_file
      copy_credentials_to_secrets_manager
    end

    def credentials_supported?
      Dir.exist?(CREDENTIALS_PATH)
    end

    def ensure_credentials_key_file
      return if File.exist?(CREDENTIALS_KEY_FILE)

      create_file CREDENTIALS_KEY_FILE, ActiveSupport::EncryptedFile.generate_key
      chmod CREDENTIALS_KEY_FILE, 0o600
    end

    def copy_credentials_to_secrets_manager
      return if secrets_manager_key_exist?(secrets_manager_credentials_key_id)

      key = run("cat #{CREDENTIALS_KEY_FILE}")
      secrets_manager.create_secret(
        description: "The Rails credentials key for #{app_config.short_name}",
        name: secrets_manager_credentials_key_id,
        secret_string: { production: key }.to_json
      )
    end

    def ensure_secret_key
      return if secrets_manager_key_exist?(secrets_manager_secret_key_id)

      key = ask 'Rails Secret Key (leave blank to generate a new one):'
      key = SecureRandom.hex(64) if key == ''
      secrets_manager.create_secret(
        description: "The Rails secret key for #{app_config.short_name}",
        name: secrets_manager_secret_key_id,
        secret_string: { production: key }.to_json
      )
    end

    def secrets_manager
      @secrets_manager ||= Aws::SecretsManager::Client.new
    end

    def aws_credentials?
      sts = Aws::STS::Client.new(region: 'us-east-1')
      sts.get_caller_identity
      true
    rescue Aws::Errors::MissingCredentialsError
      false
    end

    def ensure_application_config
      unless app_config.name
        app_config.name = ask 'Application Name:'
        app_config.short_name = ask 'Application Short Name:', default: app_config.short_name
      end

      app_config.github_org = ask 'GitHub Organization:' unless app_config.github_org
      app_config.github_repo = ask 'GitHub Repo Name:' unless app_config.github_repo

      unless app_config.valid?
        error 'There is an error in your config.'
        exit 1
      end

      template_file app_config
    end

    def app_config
      @app_config ||= ConfigFile.new(CONFIG_PATH)
    end
  end
end
