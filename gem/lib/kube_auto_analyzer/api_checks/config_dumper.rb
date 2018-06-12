module KubeAutoAnalyzer
 def self.dump_config
  @log.debug("Entering the config dumper module")
  target = @options.target_server
  @log.debug("dumping the config for #{target}")
  @results[target]['config'] = Hash.new
  pods = @client.get_pods
  docker_images = Array.new
  pods.each do |pod|
    docker_images << pod.status[:containerStatuses][0][:image]
  end
  @results[target]['config']['docker_images'] = docker_images.uniq
 end
end