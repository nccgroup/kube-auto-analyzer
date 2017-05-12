# Kubernetes Auto Analyzer

This is a configuration analyzer tool intended to automate the process of reviewing Kubernetes installations against the CIS Kubernetes 1.6 Benchmark.

It's currently under heavy development so use at your own risk :)

## Limitations

The checks currently assume that the Kubernetes API server will be running in a pod, and not directly on the underlying master node.  This limitation is in place as the way we're executing the checks is to query the API server itself and it only has information about things like command line switches in the event that its running as a pod.

Initial plans are to implement checks for all the scored items that can be queried from the API server. In the future we may do something more fancy...

## Usage

The best way to use the tool is to provide it a KUBECONFIG file to identify and authenticate the session.  in that event you can run it with

`kubeautoanalyzer.rb -c <kubeconfig_file_name> -r <report_name>`


