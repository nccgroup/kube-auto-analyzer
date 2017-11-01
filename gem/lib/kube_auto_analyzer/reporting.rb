module KubeAutoAnalyzer

  def self.json_report
    require 'json'
    @log.debug("Starting Report")
    @json_report_file.puts JSON.generate(@results) 

  end

  def self.html_report

    logo_path = File.join(__dir__, "data-logo.b64")
    logo = File.open(logo_path).read
    @log.debug("Starting HTML Report")
    @html_report_file << '
      <!DOCTYPE html>
      <head>
       <title> Kubernetes Auto Analyzer Report</title>
       <meta charset="utf-8"> 
       <style>
        body {
          font: normal 14px;
          font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
          color: #C41230;
          background: #FFFFFF;
        }
        #kubernetes-analyzer {
          font-weight: bold;
          font-size: 48px;
          color: #C41230;
        }
        .master-node, .worker-node, .vuln-node {
          background: #F5F5F5;
          border: 1px solid black;
          padding-left: 6px;
        }
        #api-server-results {
          font-weight: italic;
          font-size: 36px;
          color: #C41230;
        }
        table, th, td {
          border-collapse: collapse;
          border: 1px solid black;
        }
        th {
         font: bold 11px;
         color: #C41230;
         background: #999999;
         letter-spacing: 2px;
         text-transform: uppercase;
         text-align: left;
         padding: 6px 6px 6px 12px;
        }
        td {
        background: #FFFFFF;
        padding: 6px 6px 6px 12px;
        color: #333333;
        }
        .container{
          display: flex;
        } 
        .fixed{
          width: 300px;
        }
        .flex-item{
          flex-grow: 1;
        }
    </style>
  </head>
  <body>
  
    '
    chartkick_path = File.join(__dir__, "js_files/chartkick.js")
    chartkick = File.open(chartkick_path).read
    highcharts_path = File.join(__dir__, "js_files/highcharts.js")
    highcharts = File.open(highcharts_path).read
    @html_report_file.puts "<script>#{chartkick}</script>"
    @html_report_file.puts "<script>#{highcharts}</script>"
    @html_report_file.puts '<img width="100" height="100" align="right"' + " src=#{logo} />"
    @html_report_file.puts "<h1>Kubernetes Auto Analyzer</h1>"
    @html_report_file.puts "<br><b>Server Reviewed : </b> #{@options.target_server}"
    @html_report_file.puts '<br><br><div class="master-node"><h2>Master Node Results</h2><br>'
    #Charting setup counts for the passes and fails
    api_server_pass = 0
    api_server_fail = 0
    @results[@options.target_server]['api_server'].each do |test, result|
      if result == "Pass"
        api_server_pass  = api_server_pass + 1
      elsif result == "Fail"
        api_server_fail = api_server_fail + 1
      end
    end

    #Not a lot of point in scheduler when there's only one check...
    #scheduler_pass = 0
    #scheduler_fail = 0
    #@results[@options.target_server]['scheduler'].each do |test, result|
    #  if result == "Pass"
    #    scheduler_pass  = scheduler_pass + 1
    #  elsif result == "Fail"
    #     scheduler_fail = scheduler_fail + 1
    #  end
    #end

    controller_manager_pass = 0
    controller_manager_fail = 0
    @results[@options.target_server]['controller_manager'].each do |test, result|
      if result == "Pass"
        controller_manager_pass  = controller_manager_pass + 1
      elsif result == "Fail"
        controller_manager_fail = controller_manager_fail + 1
      end
    end

    etcd_pass = 0
    etcd_fail = 0
    @results[@options.target_server]['etcd'].each do |test, result|
      if result == "Pass"
        etcd_pass  = etcd_pass + 1
      elsif result == "Fail"
        etcd_fail = etcd_fail + 1
      end
    end

    #Start of Chart Divs
    @html_report_file.puts '<div class="container">'
    #API Server Chart
    @html_report_file.puts '<div class="fixed" id="chart-1" style="height: 300px; width: 300px; text-align: center; color: #999; line-height: 300px; font-size: 14px;font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;"></div>'
    @html_report_file.puts '<script>new Chartkick.PieChart("chart-1", {"pass": ' + api_server_pass.to_s + ', "fail": ' + api_server_fail.to_s + '}, {"colors":["green","red"], "library":{"title":{"text":"API Server Results"},"chart":{"backgroundColor":"#F5F5F5"}}})</script>'
    #Scheduler Chart
    #@html_report_file.puts '<div class="flex-item" id="chart-2" style="height: 300px; width: 300px; text-align: center; color: #999; line-height: 300px; font-size: 14px;font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;"></div>'
    #@html_report_file.puts '<script>new Chartkick.PieChart("chart-2", {"pass": ' + scheduler_pass.to_s + ', "fail": ' + scheduler_fail.to_s + '}, {"colors":["green","red"], "library":{"title":{"text":"Scheduler Results"},"chart":{"backgroundColor":"#F5F5F5"}}})</script>'
    #Controller Manager Chart
    @html_report_file.puts '<div class="fixed" id="chart-2" style="height: 300px; width: 300px; text-align: center; color: #999; line-height: 300px; font-size: 14px;font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;"></div>'
    @html_report_file.puts '<script>new Chartkick.PieChart("chart-2", {"pass": ' + controller_manager_pass.to_s + ', "fail": ' + controller_manager_fail.to_s + '}, {"colors":["green","red"], "library":{"title":{"text":"Controller Manager Results"},"chart":{"backgroundColor":"#F5F5F5"}}})</script>'
    #etcd Chart
    @html_report_file.puts '<div class="fixed" id="chart-3" style="height: 300px; width: 300px; text-align: center; color: #999; line-height: 300px; font-size: 14px;font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;"></div>'
    @html_report_file.puts '<script>new Chartkick.PieChart("chart-3", {"pass": ' + etcd_pass.to_s + ', "fail": ' + etcd_fail.to_s + '}, {"colors":["green","red"], "library":{"title":{"text":"etcd Results"},"chart":{"backgroundColor":"#F5F5F5"}}})</script>'
    #End of Chart Divs
    @html_report_file.puts '</div>'
    @html_report_file.puts "<h2>API Server</h2>"
    @html_report_file.puts "<table><thead><tr><th>Check</th><th>result</th></tr></thead>"
    @results[@options.target_server]['api_server'].each do |test, result|      
      if result == "Fail"
        result = '<span style="color:red;">Fail</span>'
      elsif result == "Pass"
        result = '<span style="color:green;">Pass</span>'
      end
      @html_report_file.puts "<tr><td>#{test}</td><td>#{result}</td></tr>"
    end
    @html_report_file.puts "</table>"
    @html_report_file.puts "<br><br>"
    @html_report_file.puts "<br><br><h2>Scheduler</h2>"
    @html_report_file.puts "<table><thead><tr><th>Check</th><th>result</th></tr></thead>"
    @results[@options.target_server]['scheduler'].each do |test, result|      
      if result == "Fail"
        result = '<span style="color:red;">Fail</span>'
      elsif result == "Pass"
        result = '<span style="color:green;">Pass</span>'
      end
      @html_report_file.puts "<tr><td>#{test}</td><td>#{result}</td></tr>"
    end
    @html_report_file.puts "</table>"

    @html_report_file.puts "<br><br>"
    @html_report_file.puts "<br><br><h2>Controller Manager</h2>"
    @html_report_file.puts "<table><thead><tr><th>Check</th><th>result</th></tr></thead>"
    @results[@options.target_server]['controller_manager'].each do |test, result|      
      if result == "Fail"
        result = '<span style="color:red;">Fail</span>'
      elsif result == "Pass"
        result = '<span style="color:green;">Pass</span>'
      end
      @html_report_file.puts "<tr><td>#{test}</td><td>#{result}</td></tr>"
    end
    @html_report_file.puts "</table>"

    @html_report_file.puts "<br><br>"
    @html_report_file.puts "<br><br><h2>etcd</h2>"
    @html_report_file.puts "<table><thead><tr><th>Check</th><th>result</th></tr></thead>"
    @results[@options.target_server]['etcd'].each do |test, result|      
      if result == "Fail"
        result = '<span style="color:red;">Fail</span>'
      elsif result == "Pass"
        result = '<span style="color:green;">Pass</span>'
      end
      @html_report_file.puts "<tr><td>#{test}</td><td>#{result}</td></tr>"
    end
    @html_report_file.puts "</table>"

    @html_report_file.puts "<br><br><h2>Evidence</h2><br>"
    @html_report_file.puts "<table><thead><tr><th>Area</th><th>Output</th></tr></thead>"
    @results[@options.target_server]['evidence'].each do |area, output|
      @html_report_file.puts "<tr><td>#{area}</td><td>#{output}</td></tr>"
    end
    #Close the master Node Div
    @html_report_file.puts "</table></div>"
    if @options.agent_checks
      @html_report_file.puts '<br><br><div class="worker-node"><h2>Worker Node Results</h2>'

      #Start of Chart Divs
      @html_report_file.puts '<div class="container">'
      @results[@options.target_server]['kubelet_checks'].each do |node, results|
        node_kubelet_pass = 0
        node_kubelet_fail = 0
        results.each do |test, result|
          if result == "Fail"
            node_kubelet_fail = node_kubelet_fail + 1
          elsif result == "Pass"
            node_kubelet_pass = node_kubelet_pass + 1
          end
        end


        #Create the Chart
        @html_report_file.puts '<div class="fixed" id="' + node + '" style="height: 300px; width: 300px; text-align: center; color: #999; line-height: 300px; font-size: 14px;font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;"></div>'
        @html_report_file.puts '<script>new Chartkick.PieChart("' + node + '", {"pass": ' + node_kubelet_pass.to_s + ', "fail": ' + node_kubelet_fail.to_s + '}, {"colors":["green","red"], "library":{"title":{"text":"' + node + ' Kubelet Results"},"chart":{"backgroundColor":"#F5F5F5"}}})</script>'

      end



      #End of Chart Divs
      @html_report_file.puts '</div>'

      @results[@options.target_server]['kubelet_checks'].each do |node, results|
        @html_report_file.puts "<br><b>#{node} Kubelet Checks</b>"
        @html_report_file.puts "<table><thead><tr><th>Check</th><th>result</th></tr></thead>"
        results.each do |test, result|
          if result == "Fail"
            result = '<span style="color:red;">Fail</span>'
          elsif result == "Pass"
            result = '<span style="color:green;">Pass</span>'
          end
          @html_report_file.puts "<tr><td>#{test}</td><td>#{result}</td></tr>"
        end
        @html_report_file.puts "</table>"
      end

      @html_report_file.puts "<br><br><h2>Evidence</h2><br>"
      @html_report_file.puts "<table><thead><tr><th>Host</th><th>Area</th><th>Output</th></tr></thead>"
      @results[@options.target_server]['node_evidence'].each do |node, evidence|
        evidence.each do |area, data|
          @html_report_file.puts "<tr><td>#{node}</td><td>#{area}</td><td>#{data}</td></tr>"   
        end
      end
      @html_report_file.puts "</table>"

    end
    #Close the Worker Node Div
    @html_report_file.puts '</div>'
    if @options.agent_checks
      @html_report_file.puts '<br><h2>Node File Permissions</h2>'
      @results[@options.target_server]['node_files'].each do |node, results|
        @html_report_file.puts "<br><b>#{node}</b><br>"
        @html_report_file.puts "<table><thead><tr><th>file</th><th>user</th><th>group</th><th>permissions</th></thead>"
        results.each do |file|
          @html_report_file.puts "<tr><td>#{file[0]}</td><td>#{file[1]}</td><td>#{file[2]}</td><td>#{file[3]}</td></tr>"
        end
        @html_report_file.puts "</table>"
      end
    end

    @html_report_file.puts '<br><h2>Vulnerability Checks</h2>'
    @html_report_file.puts '<br><h3>External Unauthenticated Access to the Kubelet</h3>'
    @html_report_file.puts "<table><thead><tr><th>Node IP Address</th><th>Result</th></thead>"
    @results[@options.target_server]['vulns']['unauth_kubelet'].each do |node, result|
      unless (result =~ /Forbidden/ || result =~ /Not Open/)
        output = "Vulnerable"
      else
        output = result
      end
      @html_report_file.puts "<tr><td>#{node}</td><td>#{output}</td></tr>"
    end
    @html_report_file.puts "</table>"
    if @options.agent_checks
      @html_report_file.puts '<br><h3>Internal Unauthenticated Access to the Kubelet</h3>'
      @html_report_file.puts "<table><thead><tr><th>Node IP Address</th><th>Result</th></thead>"
      @results[@options.target_server]['vulns']['internal_kubelet'].each do |node, result|
        unless (result =~ /Forbidden/ || result =~ /Not Open/)
          output = "Vulnerable"
        else
          output = result
        end
        @html_report_file.puts "<tr><td>#{node}</td><td>#{output}</td></tr>"
      end
      @html_report_file.puts "</table>"
    end

    @html_report_file.puts '<br><h3>External Insecure API Port Exposed</h3>'
    @html_report_file.puts "<table><thead><tr><th>Node IP Address</th><th>Result</th></thead>"
    @results[@options.target_server]['vulns']['insecure_api_external'].each do |node, result|
      unless (result =~ /Forbidden/ || result =~ /Not Open/)
        output = "Vulnerable"
      else
        output = result
      end
      @html_report_file.puts "<tr><td>#{node}</td><td>#{output}</td></tr>"
    end
    @html_report_file.puts "</table>"
    if @options.agent_checks
      @html_report_file.puts '<br><h3>Internal Insecure API Port Exposed</h3>'
      @html_report_file.puts "<table><thead><tr><th>Node IP Address</th><th>Result</th></thead>"
      @results[@options.target_server]['vulns']['insecure_api_internal'].each do |node, result|
        unless (result =~ /Forbidden/ || result =~ /Not Open/)
          output = "Vulnerable"
        else
          output = result
        end
        @html_report_file.puts "<tr><td>#{node}</td><td>#{output}</td></tr>"
      end
      @html_report_file.puts "</table>"
    end

    if @options.agent_checks
      @html_report_file.puts '<br><h3>Default Service Token In Use</h3>'
      @html_report_file.puts "<table><thead><tr><th>API endpoint</th><th>Result</th></thead>"
      @results[@options.target_server]['vulns']['service_token'].each do |node, result|
        unless (result =~ /Forbidden/ || result =~ /Not Open/)
          output = "Vulnerable"
        else
          output = result
        end
        @html_report_file.puts "<tr><td>#{node}</td><td>#{output}</td></tr>"
      end
      @html_report_file.puts "</table>"
    end

    if @options.agent_checks
      @html_report_file.puts '<br><h3>Container Configuration checks</h3>'
      @results[@options.target_server]['vulns']['amicontained'].each do |node, result|
        @html_report_file.puts "<br><b>#{node} Container Checks</b>"
        @html_report_file.puts "<table><thead><tr><th>Container item</th><th>Result</th></thead>"
        @html_report_file.puts "<tr><td>Runtime in Use</td><td>#{result['runtime']}</td></tr>"
        @html_report_file.puts "<tr><td>Host PID namespace used?</td><td>#{result['hostpid']}</td></tr>"
        @html_report_file.puts "<tr><td>AppArmor Profile</td><td>#{result['apparmor']}</td></tr>"
        @html_report_file.puts "<tr><td>User Namespaces in use?</td><td>#{result['uid_map']}</td></tr>"
        @html_report_file.puts "<tr><td>Inherited Capabilities</td><td>#{result['cap_inh']}</td></tr>"
        @html_report_file.puts "<tr><td>Effective Capabilities</td><td>#{result['cap_eff']}</td></tr>"
        @html_report_file.puts "<tr><td>Permitted Capabilities</td><td>#{result['cap_per']}</td></tr>"
        @html_report_file.puts "<tr><td>Bounded Capabilities</td><td>#{result['cap_bnd']}</td></tr>"
        @html_report_file.puts "</table>"
      end
    end




    @html_report_file.puts "<br><br><h2>Vulnerability Evidence</h2><br>"
    @html_report_file.puts "<table><thead><tr><th>Vulnerability</th><th>Host</th><th>Output</th></tr></thead>"
    @results[@options.target_server]['vulns']['unauth_kubelet'].each do |node, result|
      @html_report_file.puts "<tr><td>External Unauthenticated Kubelet Access</td><td>#{node}</td><td>#{result}</td></tr>"   
    end
    if @options.agent_checks
      @results[@options.target_server]['vulns']['internal_kubelet'].each do |node, result|
        @html_report_file.puts "<tr><td>Internal Unauthenticated Kubelet Access</td><td>#{node}</td><td>#{result}</td></tr>"   
      end
    end
    @results[@options.target_server]['vulns']['insecure_api_external'].each do |node, result|
      @html_report_file.puts "<tr><td>External Insecure API Server Access</td><td>#{node}</td><td>#{result}</td></tr>"   
    end
    if @options.agent_checks
      @results[@options.target_server]['vulns']['insecure_api_internal'].each do |node, result|
        @html_report_file.puts "<tr><td>Internal Insecure API Server Access</td><td>#{node}</td><td>#{result}</td></tr>"   
      end
    end
    if @options.agent_checks
      @results[@options.target_server]['vulns']['service_token'].each do |node, result|
        @html_report_file.puts "<tr><td>Default Service Token In Use</td><td>#{node}</td><td>#{result}</td></tr>"   
      end
    end
    if @options.agent_checks
      @results[@options.target_server]['vulns']['amicontained'].each do |node, result|
        @html_report_file.puts "<tr><td>Am I Contained Output</td><td>#{node}</td><td>#{result}</td></tr>"   
      end
    end

    @html_report_file.puts "</table>"


    #Closing the report off
    @html_report_file.puts '</body></html>'
  end
end