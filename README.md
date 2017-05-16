# Kubernetes Auto Analyzer

This is a configuration analyzer tool intended to automate the process of reviewing Kubernetes installations against the CIS Kubernetes 1.6 Benchmark.

It's currently under heavy development so use at your own risk :)

## Approach

The script currently takes the approach of extracting the command lines used to start the relevant containers (e.g. API Server, Scheduler etc) and check them against the relevant sections of the standard.  This is possible via the API server as the spec. of each container contains the command line executed.  At the moment Kubernetes doesn't have any form of API to query it's launch parameters, so this seems like the best approach.

This approach has some limitations but has the advantage of working from anywhere that has access to the API server (so doesn't need deployment on the actual nodes themselves).

One of the challenges with scripting these checks is that there are many different Kubernetes distributions, and each one does things differently, so implementing a generic script that covers them all would be tricky.

## Coverage

### Master Node Security Configuration

 - Section 1.1 - API Server - All Checks Implemented (31)
 - Section 1.2 - Scheduler - All Checks Implemented (1)
 - Section 1.3 - Controller Manager - All Checks Implemented (6)
 - Section 1.4 - Configuration Files - TBC (need separate logic to access filesystems and check permissions)
 - Section 1.5 - etcd - All Checks Implemented (6)
 - Section 1.6 - General Security Primitives - Not implementing directly.  These checks are unscored so not really suitable for automated scanning.

### Worker Node Security Configuration

 - Section 2.1 - API Config - TBC
 - Section 2.2 - Configuration Files - TBC (need separate logic to access filesystems and check permissions)

### Federated Deployments

 - Section 3.1 - Federation API Server - TBC
 - Section 3.2 - Federation Controller Manager - TBC


## Tested With

 - Kubeadm 1.5,1.6 - Works ok  
 - kube-aws - Works ok

## Usage

First up you'll need to install the gem.  Until it's in rubygems use

`gem build kube_auto_analyzer.gemspec`

then

`gem install kube_auto_analyzer-0.0.1.gem`

and that should put the kubeautoanalyzer command onto your path (assuming you have a sane ruby setup!)

The best way to use the tool is to provide it a KUBECONFIG file to identify and authenticate the session.  in that event you can run it with

`kubeautoanalyzer -c <kubeconfig_file_name> -r <report_name>`

If you've got an authorisation token for the system (e.g. with many Kubernetes 1.5 or earlier installs) you can run with

`kubeautoanalyzer -s https://<API_SERVER_IP>:<API_SERVER_PORT> -t <TOKEN> -r <report_name>`


