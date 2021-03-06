module KubeAutoAnalyzer
 def self.dump_config
  @log.debug("Entering the config dumper module")
  target = @options.target_server
  @log.debug("dumping the config for #{target}")
  @results[target][:config] = Hash.new
  pods = @client.get_pods
  services = @client.get_services
  docker_images = Array.new
  #Specific requirement here in that it's useful to know what Docker images are in use on the cluster.
  pods.each do |pod|
    docker_images << pod.status[:containerStatuses][0][:image]
  end
  @log.debug("logged #{docker_images.length} docker images")
  @results[target][:config][:docker_images] = docker_images.uniq

  @results[target][:config][:pod_info] = Array.new

  #Lets record some information about each pod
  pods.each do |pod|
    currpod = Hash.new
    currpod[:name] = pod.metadata[:name]
    currpod[:namespace] = pod.metadata[:namespace]
    currpod[:service_account] = pod.spec[:serviceAccount]
    currpod[:host_ip] = pod[:status][:hostIP]
    currpod[:pod_ip] = pod[:status][:podIP]
    @results[target][:config][:pod_info] << currpod
  end

  @results[target][:config][:service_info] = Array.new

  services.each do |service|
    currserv = Hash.new
    currserv[:name] = service.metadata[:name]
    currserv[:cluster_ip] = service.spec[:clusterIP]
    if service.spec[:externalIP]
      currserv[:external_ip] = service.spec[:externalIP]
    else
      currserv[:external_ip] = "None"
    end
    if service.spec[:ports]
      currserv[:ports] = Array.new
      service.spec[:ports].each do |port|
        currserv[:ports] << "#{port[:port]}/#{port[:protocol]}:#{port[:targetPort]}/#{port[:protocol]}"
      end
    else
      currserv[:ports] = "None"
    end
    @results[target][:config][:service_info] << currserv
  end


 end
end