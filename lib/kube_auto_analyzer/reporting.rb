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
    @log.debug("Starting HTML Report")
    @html_report_file << '
      <!DOCTYPE html>
      <head>
       <title> Kubernetes Analyzer Report</title>
       <meta charset="utf-8"> 
       <style>
        body {
          font: normal 14px auto "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
          color: #4f6b72;
          background: #E6EAE9;
        }
        #kubernetes-analyzer {
          font-weight: bold;
          font-size: 48px;
          font-family: "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
          color: #4f6b72;
        }
        #api-server-results {
          font-weight: italic;
          font-size: 36px;
          font-family: "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
          color: #4f6b72;
        }
         th {
         font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
         color: #4f6b72;
         border-right: 1px solid #C1DAD7;
         border-bottom: 1px solid #C1DAD7;
         border-top: 1px solid #C1DAD7;
         letter-spacing: 2px;
         text-transform: uppercase;
         text-align: left;
         padding: 6px 6px 6px 12px;
         }
      td {
        border-right: 1px solid #C1DAD7;
        border-bottom: 1px solid #C1DAD7;
        background: #fff;
        padding: 6px 6px 6px 12px;
        color: #4f6b72;
      }
    </style>
  </head>
  <body>
  <h1>Kubernetes Analyzer</h1>
    '
    @html_report_file.puts "<br><br><b>Server Reviewed : </b> #{@options.target_server}"
    @html_report_file.puts "<br><br><h2>API Server Results</h2><br>"
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
    @html_report_file.puts "<br><br><h2>Scheduler Results</h2><br>"
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
    @html_report_file.puts "<br><br><h2>Controller Manager Results</h2><br>"
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
    @html_report_file.puts "<br><br><h2>etcd Results</h2><br>"
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

    @html_report_file.puts "<br><br><h2>Evidence</h2><br><br>"
    @html_report_file.puts "<table><thead><tr><th>Area</th><th>Output</th></tr></thead>"
    @results[@options.target_server]['evidence'].each do |area, output|
      @html_report_file.puts "<tr><td>#{area}</td><td>#{output}</td></tr>"
    end
    @html_report_file.puts '</body></html>'
  end
end