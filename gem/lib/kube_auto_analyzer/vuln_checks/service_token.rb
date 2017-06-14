module KubeAutoAnalyzer

  #This is somewhat awkward placement.  Deployment mechanism sits more with the agent checks
  #But from a "what it's looking for" perspective, as a weakness in Kubelet, it makes more sense here.
  def self.test_service_token_internal
    require 'json'

    @log.debug("Doing the internal Service Token check")
    target = @options.target_server
    @results[target]['vulns']['service_token'] = Hash.new
    api_server_url = @client.api_endpoint.to_s
    container_name = "kaakubeletunauthtest"
    pod = Kubeclient::Resource.new
    pod.metadata = {}
    pod.metadata.name = container_name
    pod.metadata.namespace = "default"
    pod.spec = {}
    pod.spec.restartPolicy = "Never"
    pod.spec.containers = {}
    pod.spec.containers = [{name: "kubeautoanalyzerservicetokentest", image: "raesene/kaa-agent:latest"}]
    pod.spec.containers[0].args = ["/service-token-checker.rb",api_server_url]
    begin
      @log.debug("About to start Service Token Check pod")
      @client.create_pod(pod)
      @log.debug("Executed the create pod")
      begin
        sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
      rescue
        retry
      end
      @log.debug ("started Service Token Check pod")
      results = JSON.parse(@client.get_pod_log(container_name,"default"))
      results.each do |node, results|
        @results[target]['vulns']['service_token'][api_server_url] = results
      end
    ensure
      @client.delete_pod(container_name,"default")
    end
  end
end