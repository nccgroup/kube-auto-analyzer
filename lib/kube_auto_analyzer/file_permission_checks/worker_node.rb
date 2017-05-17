module KubeAutoAnalyzer

  def check_worker_etc
    pod = Kubeclient::Resource.new
    pod.metadata = {}
    pod.metadata.name = "kube-auto-analyzer-file-check"
    pod.metadata.namespace = "default"
    pod.spec = {}
    pod.spec.containers = {}
    pod.spec.containers [{name: "kubeautoanalyzerfiletest", image: "raesene/kube-auto-analyzer-agent:latest"}]
    pod.spec.volumes = [{name: 'etck8s', hostPath: {path: '/etc/kubernetes'}}]
    pod.spec.containers[0].volumeMounts = [{mountPath: '/hostetck8s', name: 'etck8s'}]
    pod.spec.containers[0].args = ["/hostetck8s"]
    @client.create_pod(pod)
    sleep(5) until @client.get_pod("kube-auto-analyzer-file-check","default")['status']['containerStatuses'][0]['state']['terminated']['reason'] == "Completed"
    results = @client.get_pod_log("kube-auto-analyzer-file-check","default")
    puts results
  end

end