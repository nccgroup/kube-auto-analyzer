module KubeAutoAnalyzer

  def self.test_unauth_kubelet_external
    #Check for whether the Kubelet port is visible outside the cluster
    nodes = Array.new
    @client.get_nodes.each do |node|
      nodes << node['status']['addresses'][0]['address']
    end

    puts (is_port_open?(nodes[0], '10250')




  end

end