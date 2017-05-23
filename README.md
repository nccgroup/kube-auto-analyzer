# Kubernetes Auto Analyzer

This is a configuration analyzer tool intended to automate the process of reviewing Kubernetes installations against the CIS Kubernetes 1.6 Benchmark.

It's currently under heavy development so use at your own risk :)

## Approach

There's two parts currently implemented by this tool, both wrapped in a ruby gem.  The first element takes the approach of extracting the command lines used to start the relevant containers (e.g. API Server, Scheduler etc) from the API and check them against the relevant sections of the standard.  This is possible via the API server as the spec. of each container contains the command line executed.  At the moment Kubernetes doesn't have any form of API to query it's launch parameters, so this seems like the best approach.

This approach has some limitations but has the advantage of working from anywhere that has access to the API server (so doesn't need deployment on the actual nodes themselves).

In addition to that we've got an agent based approach for checks on the nodes (starting with file permissions checks and process checks on kubelets).  The agent can get deployed via the Kubernetes API and then complete it's checks and place the results in the pod log which can then be read in by the script and parsed.  This is a bit on the hacky side but avoids the necessity for any form of network communications from the agent to the running script, which could well be complex.

A challenge of this approach is that we can't easily deploy to master nodes if they have NoSchedule set, so unfortunately can't use this approach for things like the Kubeadm masters.

We've started implementing checks on the kubelet processes using this approach, however a bug in 1.6.0-1.6.2 means that hostPID isn't working for those versions, so unless you have 1.6.3 this bit won't do much for now.

One of the challenges with scripting these checks is that there are many different Kubernetes distributions, and each one does things differently, so implementing a generic script that covers them all would be tricky.  We're working off kubeadm as a base, but ideally we'll get it working with as many distributions as possible.

## Coverage

### Master Node Security Configuration

 - Section 1.1 - API Server - All Checks Implemented (31)
 - Section 1.2 - Scheduler - All Checks Implemented (1)
 - Section 1.3 - Controller Manager - All Checks Implemented (6)
 - Section 1.4 - Configuration Files - TBC (need separate logic to access filesystems and check permissions on the master node)
 - Section 1.5 - etcd - All Checks Implemented (6)
 - Section 1.6 - General Security Primitives - Not implementing directly.  These checks are unscored so not really suitable for automated scanning.

### Worker Node Security Configuration

 - Section 2.1 - API Config - kubelet checks in place via kaa-agent
 - Section 2.2 - Configuration Files - Basic coverage implemented via kaa-agent.  At the moment we're providing information about file permissions back to the report as there's a lot of variety of locations and file names, it doesn't make a lot of sense to try and actually checking them to provide a pass/fail.

### Federated Deployments

 - Section 3.1 - Federation API Server - TBC
 - Section 3.2 - Federation Controller Manager - TBC


## Tested With

 - Kubeadm 1.5,1.6 - Works ok  
 - kube-aws - Works ok
 - kismatic - Works ok

## Usage

First up you'll need to install the gem. `gem install kube_auto_analyzer` should do the job and add the dependencies.

and that should put the kubeautoanalyzer command onto your path (assuming you have a sane ruby setup!)

The best way to use the tool is to provide it a KUBECONFIG file to identify and authenticate the session.  in that event you can run it with

`kubeautoanalyzer -c <kubeconfig_file_name> -r <report_name>`

If you've got an authorisation token for the system (e.g. with many Kubernetes 1.5 or earlier installs) you can run with

`kubeautoanalyzer -s https://<API_SERVER_IP>:<API_SERVER_PORT> -t <TOKEN> -r <report_name>`


## TODO

 - Add a gate to the process checks to avoid 1.6.0-1.6.2 (there's a bug with hostPID which stops it working)
 - Complete kubelet check reporting for the text report
 - Add check for service account tokens being cluster admin
 - Add check for kubelet API being available unauthenticated (can we just do that from the command line switches..)
 - Add check on authorization modes explicitly