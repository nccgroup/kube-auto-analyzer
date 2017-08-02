module KubeAutoAnalyzer

  def self.test_api_server
    @log.debug("Entering the test API Server Method")
    target = @options.target_server
    @log.debug("target is #{target}")
    @results[target]['api_server'] = Hash.new
    @results[target]['evidence'] = Hash.new
    pods = @client.get_pods
    pods.each do |pod| 
      #Ok this is a bit naive as a means of hitting the API server but hey it's a start
      if pod['metadata']['name'] =~ /kube-apiserver/
        @api_server = pod
      end
    end

    unless @api_server
      @results[target]['api_server']['API Server Pod Not Found'] = "Error"
      return
    end
    
    api_server_command_line = @api_server['spec']['containers'][0]['command']

    #Check for Allow Privileged
    unless api_server_command_line.index{|line| line =~ /--allow-privileged=false/}
      @results[target]['api_server']['CIS 1.1.1 - Ensure that the --allow-privileged argument is set to false'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.1 - Ensure that the --allow-privileged argument is set to false'] = "Pass"
    end

    #Check for Anonymous Auth
    unless api_server_command_line.index{|line| line =~ /--anonymous-auth=false/}
      @results[target]['api_server']['CIS 1.1.2 - Ensure that the --anonymous-auth argument is set to false'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.2 - Ensure that the --anonymous-auth argument is set to false'] = "Pass"
    end

    #Check for Basic Auth
    if api_server_command_line.index{|line| line =~ /--basic-auth-file/}
      @results[target]['api_server']['CIS 1.1.3 - Ensure that the --basic-auth-file argument is not set'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.3 - Ensure that the --basic-auth-file argument is not set'] = "Pass"
    end

    #Check for Insecure Allow Any Token
    if api_server_command_line.index{|line| line =~ /--insecure-allow-any-token/}
      @results[target]['api_server']['CIS 1.1.4 - Ensure that the --insecure-allow-any-token argument is not set'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.4 - Ensure that the --insecure-allow-any-token argument is not set'] = "Pass"
    end

    #Check to confirm that Kubelet HTTPS isn't set to false
    if api_server_command_line.index{|line| line =~ /--kubelet-https=false/}
      @results[target]['api_server']['CIS 1.1.5 - Ensure that the --kubelet-https argument is set to true'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.5 - Ensure that the --kubelet-https argument is set to true'] = "Pass"
    end

    #Check for Insecure Bind Address
    if api_server_command_line.index{|line| line =~ /--insecure-bind-address/}
      @results[target]['api_server']['CIS 1.1.6 - Ensure that the --insecure-bind-address argument is not set'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.6 - Ensure that the --insecure-bind-address argument is not set'] = "Pass"
    end

    #Check for Insecure Bind port
    unless api_server_command_line.index{|line| line =~ /--insecure-port=0/}
      @results[target]['api_server']['CIS 1.1.7 - Ensure that the --insecure-port argument is set to 0'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.7 - Ensure that the --insecure-port argument is set to 0'] = "Pass"
    end

    #Check Secure Port isn't set to 0
    if api_server_command_line.index{|line| line =~ /--secure-port=0/}
      @results[target]['api_server']['CIS 1.1.8 - Ensure that the --secure-port argument is not set to 0'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.8 - Ensure that the --secure-port argument is not set to 0'] = "Pass"
    end

    #
    unless api_server_command_line.index{|line| line =~ /--profiling=false/}
      @results[target]['api_server']['CIS 1.1.9 - Ensure that the --profiling argument is set to false'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.9 - Ensure that the --profiling argument is set to false'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--repair-malformed-updates/}
      @results[target]['api_server']['CIS 1.1.10 - Ensure that the --repair-malformed-updates argument is set to false'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.10 - Ensure that the --repair-malformed-updates argument is set to false'] = "Pass"
    end

    if api_server_command_line.index{|line| line =~ /--admission-control\S*AlwaysAdmit/}
      @results[target]['api_server']['CIS 1.1.11 - Ensure that the admission control policy is not set to AlwaysAdmit'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.11 - Ensure that the admission control policy is not set to AlwaysAdmit'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--admission-control\S*AlwaysPullImages/}
      @results[target]['api_server']['CIS 1.1.12 - Ensure that the admission control policy is set to AlwaysPullImages'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.12 - Ensure that the admission control policy is set to AlwaysPullImages'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--admission-control\S*DenyEscalatingExec/}
      @results[target]['api_server']['CIS 1.1.13 - Ensure that the admission control policy is set to DenyEscalatingExec'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.13 - Ensure that the admission control policy is set to DenyEscalatingExec'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--admission-control\S*SecurityContextDeny/}
      @results[target]['api_server']['CIS 1.1.14 - Ensure that the admission control policy is set to SecurityContextDeny'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.14 - Ensure that the admission control policy is set to SecurityContextDeny'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--admission-control\S*NamespaceLifecycle/}
      @results[target]['api_server']['CIS 1.1.15 - Ensure that the admission control policy is set to NamespaceLifecycle'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.15 - Ensure that the admission control policy is set to NamespaceLifecycle'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--audit-log-path/}
      @results[target]['api_server']['CIS 1.1.16 - Ensure that the --audit-log-path argument is set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.16 - Ensure that the --audit-log-path argument is set as appropriate'] = "Pass"
    end

    #TODO: This check needs to do something with the number of days but for now lets just check whether it's present.
    unless api_server_command_line.index{|line| line =~ /--audit-log-maxage/}
      @results[target]['api_server']['CIS 1.1.17 - Ensure that the --audit-log-maxage argument is set to 30 or as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.17 - Ensure that the --audit-log-maxage argument is set to 30 or as appropriate'] = "Pass"
    end

    #TODO: This check needs to do something with the number of backups but for now lets just check whether it's present.
    unless api_server_command_line.index{|line| line =~ /--audit-log-maxbackup/}
      @results[target]['api_server']['CIS 1.1.18 - Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.18 - Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate'] = "Pass"
    end

    #TODO: This check needs to do something with the size of backups but for now lets just check whether it's present.
    unless api_server_command_line.index{|line| line =~ /--audit-log-maxsize/}
      @results[target]['api_server']['CIS 1.1.19 - Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.19 - Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate'] = "Pass"
    end

    if api_server_command_line.index{|line| line =~ /--authorization-mode\S*AlwaysAllow/}
      @results[target]['api_server']['CIS 1.1.20 - Ensure that the --authorization-mode argument is not set to AlwaysAllow'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.20 - Ensure that the --authorization-mode argument is not set to AlwaysAllow'] = "Pass"
    end

    if api_server_command_line.index{|line| line =~ /--token-auth-file/}
      @results[target]['api_server']['CIS 1.1.21 - Ensure that the --token-auth-file argument is not set'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.21 - Ensure that the --token-auth-file argument is not set'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--kubelet-certificate-authority/}
      @results[target]['api_server']['CIS 1.1.22 - Ensure that the --kubelet-certificate-authority argument is set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.22 - Ensure that the --kubelet-certificate-authority argument is set as appropriate'] = "Pass"
    end

    unless (api_server_command_line.index{|line| line =~ /--kubelet-client-certificate/} && api_server_command_line.index{|line| line =~ /--kubelet-client-key/})
      @results[target]['api_server']['CIS 1.1.23 - Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.23 - Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--service-account-lookup=true/}
      @results[target]['api_server']['CIS 1.1.24 - Ensure that the --service-account-lookup argument is set to true'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.24 - Ensure that the --service-account-lookup argument is set to true'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--admission-control\S*PodSecurityPolicy/}
      @results[target]['api_server']['CIS 1.1.25 - Ensure that the admission control policy is set to PodSecurityPolicy'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.25 - Ensure that the admission control policy is set to PodSecurityPolicy'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--service-account-key-file/}
      @results[target]['api_server']['CIS 1.1.26 - Ensure that the --service-account-key-file argument is set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.26 - Ensure that the --service-account-key-file argument is set as appropriate'] = "Pass"
    end

    unless (api_server_command_line.index{|line| line =~ /--etcd-certfile/} && api_server_command_line.index{|line| line =~ /--etcd-keyfile/})
      @results[target]['api_server']['CIS 1.1.27 - Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.27 - Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--admission-control\S*ServiceAccount/}
      @results[target]['api_server']['CIS 1.1.28 - Ensure that the admission control policy is set to ServiceAccount'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.28 - Ensure that the admission control policy is set to ServiceAccount'] = "Pass"
    end

    unless (api_server_command_line.index{|line| line =~ /--tls-cert-file/} && api_server_command_line.index{|line| line =~ /--tls-private-key-file/})
      @results[target]['api_server']['CIS 1.1.29 - Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.29 - Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--client-ca-file/}
      @results[target]['api_server']['CIS 1.1.30 - Ensure that the --client-ca-file argument is set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.30 - Ensure that the --client-ca-file argument is set as appropriate'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--etcd-cafile/}
      @results[target]['api_server']['CIS 1.1.31 - Ensure that the --etcd-cafile argument is set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.31 - Ensure that the --etcd-cafile argument is set as appropriate'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--authorization-mode\S*Node/}
      @results[target]['api_server']['CIS 1.1.32 - Ensure that the --authorization-mode argument is set to Node'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.32 - Ensure that the --authorization-mode argument is set to Node'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--admission-control\S*NodeRestriction/}
      @results[target]['api_server']['CIS 1.1.33 - Ensure that the admission control policy is set to NodeRestriction'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.33 - Ensure that the admission control policy is set to NodeRestriction'] = "Pass"
    end

    unless api_server_command_line.index{|line| line =~ /--experimental-encryption-provider-config/}
      @results[target]['api_server']['CIS 1.1.34 - Ensure that the --experimental-encryption-provider-config argument is set as appropriate'] = "Fail"
    else
      @results[target]['api_server']['CIS 1.1.34 - Ensure that the --experimental-encryption-provider-config argument is set as appropriate'] = "Pass"
    end

    @results[target]['evidence']['API Server'] = api_server_command_line
  end

  def self.test_scheduler
    target = @options.target_server
    @results[target]['scheduler'] = Hash.new
    pods = @client.get_pods
    pods.each do |pod| 
      #Ok this is a bit naive as a means of hitting the API server but hey it's a start
      if pod['metadata']['name'] =~ /kube-scheduler/
        @scheduler = pod
      end
    end
    
    unless @scheduler
      @results[target]['scheduler']['Scheduler Pod Not Found'] = "Error"
      return
    end

    scheduler_command_line = @scheduler['spec']['containers'][0]['command']

    unless scheduler_command_line.index{|line| line =~ /--profiling=false/}
      @results[target]['scheduler']['CIS 1.2.1 - Ensure that the --profiling argument is set to false'] = "Fail"
    else
      @results[target]['scheduler']['CIS 1.2.1 - Ensure that the --profiling argument is set to false'] = "Pass"
    end  
    @results[target]['evidence']['Scheduler'] = scheduler_command_line
  end

  def self.test_controller_manager
    target = @options.target_server
    @results[target]['controller_manager'] = Hash.new
    pods = @client.get_pods
    pods.each do |pod| 
      #Ok this is a bit naive as a means of hitting the API server but hey it's a start
      if pod['metadata']['name'] =~ /kube-controller-manager/
        @controller_manager = pod
      end
    end

    unless @controller_manager
      @results[target]['controller_manager']['Controller Manager Pod Not Found'] = "Error"
      return
    end    


    controller_manager_command_line = @controller_manager['spec']['containers'][0]['command']

    unless controller_manager_command_line.index{|line| line =~ /--terminated-pod-gc-threshold/}
      @results[target]['controller_manager']['CIS 1.3.1 - Ensure that the --terminated-pod-gc-threshold argument is set as appropriate'] = "Fail"
    else
      @results[target]['controller_manager']['CIS 1.3.1 - Ensure that the --terminated-pod-gc-threshold argument is set as appropriate'] = "Pass"
    end 

    unless controller_manager_command_line.index{|line| line =~ /--profiling=false/}
      @results[target]['controller_manager']['CIS 1.3.2 - Ensure that the --profiling argument is set to false'] = "Fail"
    else
      @results[target]['controller_manager']['CIS 1.3.2 - Ensure that the --profiling argument is set to false'] = "Pass"
    end  

    if controller_manager_command_line.index{|line| line =~ /--insecure-experimental-approve-all-kubelet-csrs-for-group/}
      @results[target]['controller_manager']['CIS 1.3.3 - Ensure that the --insecure-experimental-approve-all-kubelet-csrs-for-group argument is not set'] = "Fail"
    else
      @results[target]['controller_manager']['CIS 1.3.3 - Ensure that the --insecure-experimental-approve-all-kubelet-csrs-for-group argument is not set'] = "Pass"
    end  

    unless controller_manager_command_line.index{|line| line =~ /--use-service-account-credentials=true/}
      @results[target]['controller_manager']['CIS 1.3.4 - Ensure that the --use-service-account-credentials argument is set to true'] = "Fail"
    else
      @results[target]['controller_manager']['CIS 1.3.4 - Ensure that the --use-service-account-credentials argument is set to true'] = "Pass"
    end 

    unless controller_manager_command_line.index{|line| line =~ /--service-account-private-key-file/}
      @results[target]['controller_manager']['CIS 1.3.5 - Ensure that the --service-account-private-key-file argument is set as appropriate'] = "Fail"
    else
      @results[target]['controller_manager']['CIS 1.3.5 - Ensure that the --service-account-private-key-file argument is set as appropriate'] = "Pass"
    end 

    unless controller_manager_command_line.index{|line| line =~ /--root-ca-file/}
      @results[target]['controller_manager']['CIS 1.3.6 - Ensure that the --root-ca-file argument is set as appropriate'] = "Fail"
    else
      @results[target]['controller_manager']['CIS 1.3.6 - Ensure that the --root-ca-file argument is set as appropriate'] = "Pass"
    end 

    @results[target]['evidence']['Controller Manager'] = controller_manager_command_line

  end

  def self.test_etcd
    target = @options.target_server
    @results[target]['etcd'] = Hash.new
    pods = @client.get_pods
    pods.each do |pod| 
      #Ok this is a bit naive as a means of hitting the API server but hey it's a start
      if pod['metadata']['name'] =~ /etcd/
        @etcd = pod
      end
    end
    
    unless @etcd
      @results[target]['etcd']['etcd Pod Not Found'] = "Error"
      return
    end

    etcd_command_line = @etcd['spec']['containers'][0]['command']

    unless (etcd_command_line.index{|line| line =~ /--cert-file/} && etcd_command_line.index{|line| line =~ /--key-file/})
      @results[target]['etcd']['CIS 1.5.1 - Ensure that the --cert-file and --key-file arguments are set as appropriate'] = "Fail"
    else
      @results[target]['etcd']['CIS 1.5.1 - Ensure that the --cert-file and --key-file arguments are set as appropriate'] = "Pass"
    end 

    unless etcd_command_line.index{|line| line =~ /--client-cert-auth=true/}
      @results[target]['etcd']['CIS 1.5.2 - Ensure that the --client-cert-auth argument is set to true'] = "Fail"
    else
      @results[target]['etcd']['CIS 1.5.2 - Ensure that the --client-cert-auth argument is set to true'] = "Pass"
    end

    if etcd_command_line.index{|line| line =~ /--auto-tls argument=true/}
      @results[target]['etcd']['CIS 1.5.3 - Ensure that the --auto-tls argument is not set to true'] = "Fail"
    else
      @results[target]['etcd']['CIS 1.5.3 - Ensure that the --auto-tls argument is not set to true'] = "Pass"
    end

    unless (etcd_command_line.index{|line| line =~ /--peer-cert-file/} && etcd_command_line.index{|line| line =~ /--peer-key-file/})
      @results[target]['etcd']['CIS 1.5.4 - Ensure that the --peer-cert-file and --peer-key-file arguments are set as appropriate'] = "Fail"
    else
      @results[target]['etcd']['CIS 1.5.4 - Ensure that the --peer-cert-file and --peer-key-file arguments are set as appropriate'] = "Pass"
    end 

    unless etcd_command_line.index{|line| line =~ /--peer-client-cert-auth=true/}
      @results[target]['etcd']['CIS 1.5.5 - Ensure that the --peer-client-cert-auth argument is set to true'] = "Fail"
    else
      @results[target]['etcd']['CIS 1.5.5 - Ensure that the --peer-client-cert-auth argument is set to true'] = "Pass"
    end

    if etcd_command_line.index{|line| line =~ /--peer-auto-tls argument=true/}
      @results[target]['etcd']['CIS 1.5.6 - Ensure that the --peer-auto-tls argument is not set to true'] = "Fail"
    else
      @results[target]['etcd']['CIS 1.5.6 - Ensure that the --peer-auto-tls argument is not set to true'] = "Pass"
    end



    @results[target]['evidence']['etcd'] = etcd_command_line
  end
end