module KubeAutoAnalyzer

  def self.test_insecure_api_external
    @log.debug("Doing the external Insecure API check")
    target = @options.target_server
    unless @results[target]['vulns']
      @results[target]['vulns'] = Hash.new
    end
    @results[target]['vulns']['insecure_api_external'] = Hash.new
    #Check for whether the Insecure API port is visible outside the cluster
    nodes = Array.new
    @client.get_nodes.each do |node|
      nodes << node['status']['addresses'][0]['address']
    end
    nodes.each do |nod|
      if is_port_open?(nod, 8080)
        begin
          pods_resp = RestClient::Request.execute(:url => "http://#{nod}:8080/api",:method => :get)
        rescue RestClient::Forbidden
          pods_resp = "Not Vulnerable - Request Forbidden"
        rescue RestClient::NotFound
          pods_resp = "Not Vulnerable - Request Not Found"
        end
        @results[target]['vulns']['insecure_api_external'][nod] = pods_resp
      else
        @results[target]['vulns']['insecure_api_external'][nod] = "Not Vulnerable - Port Not Open"
      end
    end
  end

  #This is somewhat awkward placement.  Deployment mechanism sits more with the agent checks
  #But from a "what it's looking for" perspective, as a weakness in API Server, it makes more sense here.
  def self.test_insecure_api_internal
    require 'json'

    @log.debug("Doing the internal Insecure API Server check")
    target = @options.target_server
    @results[target]['vulns']['insecure_api_internal'] = Hash.new
    nodes = Array.new
    @client.get_nodes.each do |node|
      nodes << node['status']['addresses'][0]['address']
    end
    container_name = "kaainsecureapitest"
    pod = Kubeclient::Resource.new
    pod.metadata = {}
    pod.metadata.name = container_name
    pod.metadata.namespace = "default"
    pod.spec = {}
    pod.spec.restartPolicy = "Never"
    pod.spec.containers = {}
    pod.spec.containers = [{name: "kubeautoanalyzerapitest", image: "raesene/kaa-agent:latest"}]
    pod.spec.containers[0].args = ["/api-server-checker.rb",nodes.join(',')]
    begin
      @log.debug("About to start API Server check pod")
      @client.create_pod(pod)
      @log.debug("Executed the create pod")
      sleep_count = 0
      begin
        sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
        sleep_count = sleep_count + 1
        @log.debug("Waited #{(5 * sleep_count).to_s} seconds for the API Server Check Pod")
      rescue
        retry
      end
      @log.debug ("started Kube API Check pod")
      results = JSON.parse(@client.get_pod_log(container_name,"default"))
      results.each do |node, results|
        @results[target]['vulns']['insecure_api_internal'][node] = results
      end
    ensure
      @client.delete_pod(container_name,"default")
    end
  end
end