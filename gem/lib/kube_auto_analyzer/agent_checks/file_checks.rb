module KubeAutoAnalyzer

  def self.check_files
    require 'json'
    @log.debug ("entering File check")
    target = @options.target_server
    @results[target]['node_files'] = Hash.new


    nodes = Array.new
    @client.get_nodes.each do |node|
      nodes << node
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

      #Try the Toleration for Master
      pod.spec.tolerations = {}
      pod.spec.tolerations = [{ key:"key", operator:"Equal", value:"value",effect:"NoSchedule"}]
      
      pod.spec.volumes = [{name: 'etck8s', hostPath: {path: '/etc'}}]
      pod.spec.containers[0].volumeMounts = [{mountPath: '/etc', name: 'etck8s'}]
      pod.spec.containers[0].args = ["/file-checker.rb","/etc/kubernetes"]
      pod.spec.nodeselector = {}
      begin
        pod.spec.nodeselector['kubernetes.io/hostname'] = node_hostname
        @client.create_pod(pod)
        begin
          sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
        rescue
          retry
        end
        files = JSON.parse(@client.get_pod_log(container_name,"default"))
      
        @results[target]['node_files'][node_hostname] = files
      ensure
        @client.delete_pod(container_name,"default")
      end

    end
    @log.debug("Finished Node File Check")
  end

end