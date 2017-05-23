module KubeAutoAnalyzer

  def self.check_kubelet_process
    @log.debug("Entering Process Checks")
    target = @options.target_server
    @results[target]['kubelet_checks'] = Hash.new
    @results[target]['node_evidence'] = Hash.new


    nodes = Array.new
    @client.get_nodes.each do |node|
      unless node.spec.taints.to_s =~ /NoSchedule/
        nodes << node
      end
    end

    nodes.each do |nod|
      node_hostname = nod.metadata.labels['kubernetes.io/hostname']
      container_name = "kaa" + node_hostname
      pod = Kubeclient::Resource.new
      pod.metadata = {}
      pod.metadata.name = container_name
      pod.metadata.namespace = "default"
      pod.spec = {}
      pod.spec.restartPolicy = "Never"
      pod.spec.containers = {}
      pod.spec.containers = [{name: "kaakubelettest", image: "raesene/kaa-agent:latest"}]
      pod.spec.containers[0].args = ["/process-checker.rb"]
      pod.spec.hostPID = true
      pod.spec.nodeselector = {}
      pod.spec.nodeselector['kubernetes.io/hostname'] = node_hostname
      begin
        @client.create_pod(pod)
        begin
          sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
        rescue
          retry
        end
        processes = JSON.parse(@client.get_pod_log(container_name,"default"))
        #If we didn't get more than one process, we're probably not reading the host ones
        #So either it's a bug or we don't have rights
        if processes.length < 2
          @log.debug("Process Check failed didn't get the node process list")
          @results[target]['kubelet_checks'][node_hostname]['Kubelet Not Found'] = "Error - couldn't see host process list"
          @client.delete_pod(container_name,"default")
          return
        end
        #puts processes
        kubelet_proc = ''
        processes.each do |proc|
          if proc =~ /kubelet/
            kubelet_proc = proc
          end
        end
        @results[target]['kubelet_checks'][node_hostname] = Hash.new
        unless kubelet_proc.length > 1
          @results[target]['kubelet_checks'][node_hostname]['Kubelet Not Found'] = "Error"
          @log.debug(processes)
          @client.delete_pod(container_name,"default")
          return
        end

        @results[target]['node_evidence'][node_hostname] = Hash.new
        @results[target]['node_evidence'][node_hostname]['kubelet'] = kubelet_proc


        
        #Checks
        unless kubelet_proc =~ /--allow-privileged=false/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.1 - Ensure that the --allow-privileged argument is set to false'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.1 - Ensure that the --allow-privileged argument is set to false'] = "Pass"
        end

        unless kubelet_proc =~ /--anonymous-auth=false/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.2 - Ensure that the --anonymous-auth argument is set to false'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.2 - Ensure that the --anonymous-auth argument is set to false'] = "Pass"
        end

        if kubelet_proc =~ /--authorization-mode\S*AlwaysAllow/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.3 - Ensure that the --authorization-mode argument is not set to AlwaysAllow'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.3 - Ensure that the --authorization-mode argument is not set to AlwaysAllow'] = "Pass"
        end

        unless kubelet_proc =~ /--client-ca-file/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.4 - Ensure that the --client-ca-file argument is set as appropriate'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.4 - Ensure that the --client-ca-file argument is set as appropriate'] = "Pass"
        end

        unless kubelet_proc =~ /--read-only-port=0/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.5 - Ensure that the --read-only-port argument is set to 0'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.5 - Ensure that the --read-only-port argument is set to 0'] = "Pass"
        end

        if kubelet_proc =~ /--streaming-connection-idle-timeout=0/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.6 - Ensure that the --streaming-connection-idle-timeout argument is not set to 0'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.6 - Ensure that the --streaming-connection-idle-timeout argument is not set to 0'] = "Pass"
        end

        unless kubelet_proc =~ /--protect-kernel-defaults=true/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.7 - Ensure that the --protect-kernel-defaults argument is set to true'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.7 - Ensure that the --protect-kernel-defaults argument is set to true'] = "Pass"
        end

        if kubelet_proc =~ /--make-iptables-util-chains=false/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.8 - Ensure that the --make-iptables-util-chains argument is set to true'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.8 - Ensure that the --make-iptables-util-chains argument is set to true'] = "Pass"
        end

        unless kubelet_proc =~ /--keep-terminated-pod-volumes=false/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.9 - that the --keep-terminated-pod-volumes argument is set to false'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.9 - Ensure that the --keep-terminated-pod-volumes argument is set to false'] = "Pass"
        end

        if kubelet_proc =~ /--hostname-override/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.10 - Ensure that the --hostname-override argument is not set'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.10 - Ensure that the --hostname-override argument is not set'] = "Pass"
        end      

        unless kubelet_proc =~ /--event-qps=0/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.11 - Ensure that the --event-qps argument is set to 0'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.11 - Ensure that the --event-qps argument is set to 0'] = "Pass"
        end

        unless (kubelet_proc =~ /--tls-cert-file/) && (kubelet_proc =~ /--tls-private-key-file/)
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.12 - Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.12 - Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate'] = "Pass"
        end

        unless kubelet_proc =~ /--cadvisor-port=0/
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.13 - Ensure that the --cadvisor-port argument is set to 0'] = "Fail"
        else
          @results[target]['kubelet_checks'][node_hostname]['CIS 2.1.13 - Ensure that the --cadvisor-port argument is set to 0'] = "Pass"
        end
      #Need an ensure block here to make sure that the pod is deleted after its run  
      ensure
        @client.delete_pod(container_name,"default")
      end

    end

  end

end