module KubeAutoAnalyzer

  def self.check_files
    require 'json'
    @log.debug ("entering File check")
    target = @options.target_server
    @results[target]['worker_files'] = Hash.new

    #Run on any nodes that aren't NoSchedule
    #Doesn't necessarily mean worker nodes, but a reasonable facsimile for now.
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
      pod.spec.containers = [{name: "kubeautoanalyzerfiletest", image: "raesene/kaa-agent:latest"}]
      pod.spec.volumes = [{name: 'etck8s', hostPath: {path: '/etc'}}]
      pod.spec.containers[0].volumeMounts = [{mountPath: '/etc', name: 'etck8s'}]
      pod.spec.containers[0].args = ["/file-checker.rb","/etc/kubernetes"]
      pod.spec.nodeselector = {}
      pod.spec.nodeselector['kubernetes.io/hostname'] = node_hostname
      @client.create_pod(pod)
      begin
        sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
      rescue
        retry
      end
      files = JSON.parse(@client.get_pod_log(container_name,"default"))
      #files.each do |file|
        #Need to replace the mounted path with the real host path
      #  file[0].sub! "/hostetck8s", "/etc/kubernetes"
      #end
      @results[target]['worker_files'][node_hostname] = files
      @client.delete_pod(container_name,"default")

    end
    @log.debug("Finished Worker File Check")
  end

end