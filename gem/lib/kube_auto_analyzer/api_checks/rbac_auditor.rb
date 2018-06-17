module KubeAutoAnalyzer
  def self.audit_rbac
    @log.debug("Entering the RBAC Auditor")
    target = @options.target_server
    @log.debug("Auditing RBAC on #{target}")
    @results[target][:rbac] = Hash.new
    cluster_roles = @rbac_client.get_cluster_roles
    @log.debug("got #{cluster_roles.length.to_s} cluster roles")
    cluster_role_bindings = @rbac_client.get_cluster_role_bindings
    @log.debug("got #{cluster_role_bindings.length.to_s} cluster role bindings")
    @results[target][:rbac][:cluster_roles] = Hash.new
    cluster_roles.each do |role|
      role_output = Hash.new
      role_output[:rules] = role.rules

      @log.debug("metadata in #{role.metadata[:name]} , #{role.metadata}")
      begin
        if role.metadata[:labels]['kubernetes.io/bootstrapping'] == "rbac-defaults"
          role_output[:default] = true
        else
          role_output[:default] = false
        end
      rescue NoMethodError
        #If there's no method, it can't be a default...
        role_output[:default] = false
      end
      role_output[:subjects] = Array.new
      cluster_role_bindings.each do |binding|
        #So we're testing if the binding has any subjects and if so whether they apply to this role or not
        if binding.subjects 
          @log.debug("#{binding.roleRef[:name]} binding has #{binding.subjects.length.to_s} bindings")
        else
          @log.debug("#{binding.roleRef[:name]} has no subjects")
        end
        @log.debug(binding.roleRef[:kind] + ", " + role.metadata[:name] + ", " + binding.roleRef[:name] + ", " + (binding.subjects ? binding.subjects.length.to_s : "0") )
        if binding.roleRef[:kind] == "ClusterRole"
          @log.debug("Matched the cluster role")
          if binding.roleRef[:name] == role.metadata[:name]
            @log.debug("matched the role name")
            if binding.subjects
              binding.subjects.each do |subject|
                @log.debug("added a subject to the list")
                role_output[:subjects] << subject
              end
            end
          end
        end
      end
      @results[target][:rbac][:cluster_roles][role.metadata[:name]] = role_output
    end
  end
end