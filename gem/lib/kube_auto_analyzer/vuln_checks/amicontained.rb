module KubeAutoAnalyzer

  #This is somewhat awkward placement.  Deployment mechanism sits more with the agent checks
  #But from a "what it's looking for" perspective, its more with the vuln. checks as there's not a CIS check for it.
  def self.check_amicontained

    @log.debug("Doing Am I contained check")
    target = @options.target_server
    @results[target]['vulns']['amicontained'] = Hash.new

    nodes = Array.new
    @client.get_nodes.each do |node|
      nodes << node['status']['addresses'][0]['address']
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
      pod.spec.containers = [{name: "kubeautoanalyzerkubelettest", image: "raesene/kaa-agent:latest"}]
      pod.spec.containers[0].args = ["/usr/local/bin/amicontained"]
      pod.spec.nodeselector = {}
      pod.spec.nodeselector['kubernetes.io/hostname'] = node_hostname
      begin
        @log.debug("About to start amicontained pod")
        @client.create_pod(pod)
        @log.debug("Executed the create pod")
        begin
          sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
        rescue
          retry
        end
        @log.debug ("started amicontained pod")
        results = @client.get_pod_log(container_name,"default")
        @results[target]['vulns']['amicontained'][nod] = results
      ensure
        @client.delete_pod(container_name,"default")
      end
    end
  end
end