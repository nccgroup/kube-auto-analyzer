module KubeAutoAnalyzer
  def self.check_authz
    @log.debug("Entering the authorization checker")
    target = @options.target_server
    @log.debug("Checking enabled authorization options on #{target}")
    @results[target][:authz] = Hash.new
    pods = @client.get_pods
    pods.each do |pod|
      if pod['metadata']['name'] =~ /kube-apiserver/
        @api_server = pod
      end
    end

    api_server_command_line = @api_server['spec']['containers'][0]['command']
    if api_server_command_line.index{|line| line =~ /--authorization-mode\S*RBAC/}
      @results[target][:authz][:rbac] = true
      
    else
      @results[target][:authz][:rbac] = false      
    end

    if api_server_command_line.index{|line| line =~ /--authorization-mode\S*ABAC/}
      @results[target][:authz][:abac] = true
    else
      @results[target][:authz][:abac] = false
    end

    if api_server_command_line.index{|line| line =~ /--authorization-mode\S*Webhook/}
      @results[target][:authz][:webhook] = true
    else
      @results[target][:authz][:webhook] = false
    end
  end
end