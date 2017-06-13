module KubeAutoAnalyzer

  def self.test_unauth_kubelet_external
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
        end
        @results[target]['vulns']['unauth_kubelet'][nod] = pods_resp
      else
        @results[target]['vulns']['unauth_kubelet'][nod] = "Not Vulnerable - Port Not Open"
      end
    end
  end
end