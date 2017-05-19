module KubeAutoAnalyzer

  def self.check_kubelet_process
    @log.debug("Entering Process Checks")
    target = @options.target_server
    @results[target]['kubelet_checks'] = Hash.new


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
      @client.create_pod(pod)
      begin
        sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
      rescue
        retry
      end
      processes = JSON.parse(@client.get_pod_log(container_name,"default"))
      puts processes
      processes.each do |proc|
        if proc =~ /kubelet/
          kubelet_proc = proc
        end
      end

      #Checks
      #puts kubelet_proc

      #@results[target]['kubelet_checks'][node_hostname] = files
      @client.delete_pod(container_name,"default")

    end

  end

end