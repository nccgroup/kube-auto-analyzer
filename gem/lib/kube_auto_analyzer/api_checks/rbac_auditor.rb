module KubeAutoAnalzyer
  def self.audit_rbac
    @log.debug("Entering the RBAC Auditor")
    target = @options.target_server
    @log.debug("Auditing RBAC on #{target}")
    @results[target][:rbac] = Hash.new
    cluster_roles = @rbac_client.get_cluster_roles
    @log.debug("got #{cluster_roles.length.to_s} cluster roles")
    cluster_role_bindings = @rbac_client.get_cluster_role_bindings
    @log.debug("got #{cluster_role_bindings.length.to_s} cluster role bindings")
  end
end