module KubeAutoAnalyzer
  attr_accessor :execute
  require "kube_auto_analyzer/version"
  require "kube_auto_analyzer/api_checks/master_node"
  require "kube_auto_analyzer/api_checks/config_dumper"
  require "kube_auto_analyzer/api_checks/rbac_auditor"
  require "kube_auto_analyzer/reporting"
  require "kube_auto_analyzer/agent_checks/file_checks"
  require "kube_auto_analyzer/agent_checks/process_checks"
  require "kube_auto_analyzer/vuln_checks/kubelet"
  require "kube_auto_analyzer/vuln_checks/api_server"
  require "kube_auto_analyzer/vuln_checks/service_token"
  require "kube_auto_analyzer/vuln_checks/amicontained"
  require "kube_auto_analyzer/utility/network"
  

  def self.execute(commmand_line_opts)
    @options = commmand_line_opts
    require 'logger'
    begin
      require 'kubeclient'
    rescue LoadError
      puts "You need to install kubeclient for this, try 'gem install kubeclient'"
      exit
    end

    @base_dir = @options.report_directory
    if !File.exists?(@base_dir)
      Dir.mkdirs(@base_dir)
    end

    @log = Logger.new(@base_dir + '/kube-analyzer-log.txt')
    @log.level = Logger::DEBUG
    @log.debug("Log created at " + Time.now.to_s)
    @log.debug("Target API Server is " + @options.target_server)

    @report_file_name = @base_dir + '/' + @options.report_file
    if @options.json_report
      @json_report_file = File.new(@report_file_name + '.json','w+')
    end

    if @options.html_report
      @html_report_file = File.new(@report_file_name + '.html','w+')
    end
    @log.debug("New Report File created #{@report_file_name}")
        
    @results = Hash.new
    #TODO: Expose this as an option rather than hard-code to off
    unless @options.config_file
      ssl_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      #TODO: Need to setup the other authentication options
      if @options.token.length > 1
        auth_options = { bearer_token: @options.token}
      elsif @options.token_file.length > 1
        auth_options = { bearer_token_file: @options.token_file}
      elsif @options.insecure 
        #Not sure this will actually work for no auth. needed, try and ooold cluster to check
        auth_options = {}
      end
      @results[@options.target_server] = Hash.new
      @client = Kubeclient::Client.new @options.target_server, 'v1', auth_options: auth_options, ssl_options: ssl_options
      @rbac_client = Kubeclient::Client.new @options.target_server + '/apis/rbac.authorization.k8s.io', 'v1', auth_options: auth_options, ssl_options: ssl_options
    else
      begin
        config = Kubeclient::Config.read(@options.config_file)
        if @options.context
          context = config.context(@options.context)
        else
          context = config.context
        end
      rescue Errno::ENOENT
        puts "Config File could not be read, check the path?"
        exit
      end
      if @options.nosslverify
        @client = Kubeclient::Client.new(
          context.api_endpoint,
          context.api_version,
          {
            ssl_options: {client_cert: context.ssl_options[:client_cert], client_key: context.ssl_options[:client_key],verify_ssl: OpenSSL::SSL::VERIFY_NONE},
            auth_options: context.auth_options
          }
        )
        @rbac_client = Kubeclient::Client.new(
          context.api_endpoint + '/apis/rbac.authorization.k8s.io',
          context.api_version,
          {
            ssl_options: {client_cert: context.ssl_options[:client_cert], client_key: context.ssl_options[:client_key],verify_ssl: OpenSSL::SSL::VERIFY_NONE},
            auth_options: context.auth_options
          }
        )
      else
        @client = Kubeclient::Client.new(
          context.api_endpoint,
          context.api_version,
          {
            ssl_options: context.ssl_options,
            auth_options: context.auth_options
          }
        )
        @rbac_client = Kubeclient::Client.new(
          context.api_endpoint + '/apis/rbac.authorization.k8s.io',
          context.api_version,
          {
            ssl_options: context.ssl_options,
            auth_options: context.auth_options
          }
        )
      end
      #We didn't specify the target on the command line so lets get it from the config file
      @options.target_server = context.api_endpoint
      @log.debug("target is " + @options.target_server)
      @results[context.api_endpoint] = Hash.new
    end
    #Test response
    begin
      @client.get_pods.to_s
    rescue => error
      puts error
      puts "Check of API connection failed."
      puts "try using kubectl with the same connection details"
      puts "to see what's going wrong."
      exit
    end
    test_api_server
    test_scheduler
    test_controller_manager
    test_etcd
    test_unauth_kubelet_external
    test_insecure_api_external
    if @options.agent_checks
      test_unauth_kubelet_internal
      test_insecure_api_internal
      test_service_token_internal
      check_files
      check_kubelet_process
      check_amicontained
    end
    if @options.dump_config
      dump_config
    end
    if @options.audit_rbac
      audit_rbac
    end
    if @options.html_report
      html_report
    end
    if @options.json_report
      json_report
    end
  end


end
