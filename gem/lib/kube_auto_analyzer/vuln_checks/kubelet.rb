module KubeAutoAnalyzer

  def self.test_unauth_kubelet_external
    @log.debug("Doing the external kubelet check")
    target = @options.target_server
    unless @results[target]['vulns']
      @results[target]['vulns'] = Hash.new
    end
    @results[target]['vulns']['unauth_kubelet'] = Hash.new
    #Check for whether the Kubelet port is visible outside the cluster
    nodes = Array.new
    @client.get_nodes.each do |node|
      nodes << node['status']['addresses'][0]['address']
    end
    nodes.each do |nod|
      if is_port_open?(nod, 10250)
        begin
          pods_resp = RestClient::Request.execute(:url => "https://#{nod}:10250/runningpods",:method => :get, :verify_ssl => false)
        rescue RestClient::Forbidden
          pods_resp = "Not Vulnerable - Request Forbidden"
        rescue RestClient::Unauthorized
          pods_resp = "Not Vulnerable - Request Unauthorized"
        end
        @results[target]['vulns']['unauth_kubelet'][nod] = pods_resp
      else
        @results[target]['vulns']['unauth_kubelet'][nod] = "Not Vulnerable - Port Not Open"
      end
    end
  end

  #This is somewhat awkward placement.  Deployment mechanism sits more with the agent checks
  #But from a "what it's looking for" perspective, as a weakness in Kubelet, it makes more sense here.
  def self.test_unauth_kubelet_internal
    require 'json'

    @log.debug("Doing the internal kubelet check")
    target = @options.target_server
    @results[target]['vulns']['internal_kubelet'] = Hash.new
    nodes = Array.new
    @client.get_nodes.each do |node|
      nodes << node['status']['addresses'][0]['address']
    end
    container_name = "kaakubeletunauthtest"
    pod = Kubeclient::Resource.new
    pod.metadata = {}
    pod.metadata.name = container_name
    pod.metadata.namespace = "default"
    pod.spec = {}
    pod.spec.restartPolicy = "Never"
    pod.spec.containers = {}
    pod.spec.containers = [{name: "kubeautoanalyzerkubelettest", image: "raesene/kaa-agent:latest"}]
    pod.spec.containers[0].args = ["/kubelet-checker.rb",nodes.join(',')]
    begin
      @log.debug("About to start Kubelet check pod")
      @client.create_pod(pod)
      @log.debug("Executed the create pod")
      begin
        sleep(5) until @client.get_pod(container_name,"default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
      rescue
        retry
      end
      @log.debug ("started Kubelet Check pod")
      results = JSON.parse(@client.get_pod_log(container_name,"default"))
      results.each do |node, results|
        @results[target]['vulns']['internal_kubelet'][node] = results
      end
    ensure
      @client.delete_pod(container_name,"default")
    end
  end
end