module KubeAutoAnalyzer
  def self.report
    @log.debug("Starting Report")
    @report_file.puts "Kubernetes Analyzer"
    @report_file.puts "===================\n\n"
    @report_file.puts "**Server Reviewed** : #{@options.target_server}"
    @report_file.puts "\n\nAPI Server Results"
    @report_file.puts "----------------------\n\n"
    @results[@options.target_server]['api_server'].each do |test, result|
      @report_file.puts '* ' + test + ' - **' + result + '**'
    end
    @report_file.puts "\n\nScheduler Results"
    @report_file.puts "----------------------\n\n"
    @results[@options.target_server]['scheduler'].each do |test, result|
      @report_file.puts '* ' + test + ' - **' + result + '**'
    end

    @report_file.puts "\n\nController Manager Results"
    @report_file.puts "----------------------\n\n"
    @results[@options.target_server]['controller_manager'].each do |test, result|
      @report_file.puts '* ' + test + ' - **' + result + '**'
    end

    @report_file.puts "\n\netcd Results"
    @report_file.puts "----------------------\n\n"
    @results[@options.target_server]['etcd'].each do |test, result|
      @report_file.puts '* ' + test + ' - **' + result + '**'
    end

    @report_file.puts "\n\nEvidence"
    @report_file.puts "---------------\n\n"
    @report_file.puts '    ' + @results[@options.target_server]['evidence']['API Server'].to_s
    @report_file.puts "---------------\n\n"
    @report_file.puts '    ' + @results[@options.target_server]['evidence']['Scheduler'].to_s
    @report_file.puts "---------------\n\n"
    @report_file.puts '    ' + @results[@options.target_server]['evidence']['Controller Manager'].to_s
    @report_file.puts "---------------\n\n"
    @report_file.puts '    ' + @results[@options.target_server]['evidence']['etcd'].to_s
    @report_file.close
  end

  def self.html_report
    base_report = File.open(@report_file_name + '.txt','r').read
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
        .master-node {
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
    </style>
  </head>
  <body>
  
    '
    @html_report_file.puts '<img width="100" height="100" align="right"' + " src=#{logo} />"
    @html_report_file.puts "<h1>Kubernetes Auto Analyzer</h1>"
    @html_report_file.puts "<br><b>Server Reviewed : </b> #{@options.target_server}"
    @html_report_file.puts '<br><br><div class="master-node"><h2>Master Node Results</h2><br>'
    @html_report_file.puts "<h2>API Server Results</h2>"
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
    @html_report_file.puts "<br><br><h2>Scheduler Results</h2>"
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
    @html_report_file.puts "<br><br><h2>Controller Manager Results</h2>"
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
    @html_report_file.puts "<br><br><h2>etcd Results</h2>"
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
    @html_report_file.puts '<br><br><div class="worker-node"><h2>Worker Node Results</h2><br>'
    @html_report_file.puts '</body></html>'
  end
end