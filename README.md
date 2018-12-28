# Kubernetes Auto Analyzer

This is a Kubernetes Security configuration review tool it's designed to automate the process of checking specific items on cluster security.

It also has some ability to audit against the CIS Kubernetes benchmark, however this isn't really mantained at the moment, so if this is a feature you need, consider checking out [Aqua's Kube-Bench](https://github.com/aquasecurity/kube-bench)

## Getting Started

There's two ways to run the analyzer either as a ruby gem or using docker.

### Docker

Unsurprisingly there's an image on Docker hub.  To run you'll need to put the config file (if you're using one) in a directory that can be accessed by the docker container and then mount it as a volume to /data in the container e.g.

`docker run -v /data:/data raesene/kube_auto_analyzer -c /data/admin.conf -r testdock`

### Ruby Gem

#### Pre-requisites

For the gem install you'll need some development libs to get it working. In general a ruby version of 2.1+ and the ruby-dev and build-essential packages should work on debian based distributions.  For Amazon Linux this set of commands should work

```
sudo yum groupinstall "Development Tools"
sudo yum install ruby24 ruby24-devel
sudo alternatives --set ruby /usr/bin/ruby2.4
gem install kube_auto_analyzer
```

#### Gem Install

To install the ruby gem , just do `gem install kube_auto_analyzer` and that should put the kubeautoanalyzer command onto your path (assuming you have a sane ruby setup!)


#### Operation

By default the analyzer will check enabled authentication and authorization mechanisms, check a couple of common vulnerabilities and then create an HTML report.  There are other options to make things more useful, which are detailed below.

The best way to use the tool is to provide it a KUBECONFIG file to identify and authenticate the session.  in that event you can run it with

`kubeautoanalyzer -c <kubeconfig_file_name> -r <report_name> `

If there are multiple contexts in your Kubeconfig file and you don't want to use the one specified as "current-context" then you can specify one on the commmand line with

`kubeautoanalyzer -c <kubeconfig_file_name> --context=<context_name> -r <report_name>`

If you've got an authorisation token for the system (e.g. with many Kubernetes 1.5 or earlier installs) you can run with

`kubeautoanalyzer -s https://<API_SERVER_IP>:<API_SERVER_PORT> -t <TOKEN> -r <report_name>`

If you've got access to the insecure API port and would like to run against that, you can run with

`kubeautoanalyzer -s http://<API_SERVER_IP>:<INSECURE_PORT> -i -r <report_name>`

Running `kubeautoanalyzer` without any switches will provide information on the command line switches available.

#### Additional Options

For the API server based checking there are a couple of additional options which can be supplied to extract additional information from the cluster.

`--dump` - This will dump some additional information out of the cluster, including running pods and services, and Docker images in-use.
`--rbac` - This is an early stage attempt to provide some inforamtion about the RBAC roles and rolebindings available on the cluster.  At the moment it only does clusterroles and clusterrolebindings, but the intent would be to add namespaced roles and rolebindings in the future.

#### CIS Audit

If you want to do some CIS audit checks against the server (carried out at the Kubernetes 1.8 version of the standard), add `-a` or `--audit` to the command line.

## Agent Checks

**Warning: Experimental**

The `--agentChecks` switch will deploy a container onto each node in the cluster to try and complete various checks that need to run from the node. Your cluster need to be able to pull from Docker hub for this to work.

This will also slow things down a bit (depending on your network/cluster speed)

## Reporting

There are two reporting modes available, JSON and HTML.  The HTML is intended for humans to read and the JSON for input to other tools.  The HTML report should looks something like this.

![Report Example](https://raw.githubusercontent.com/nccgroup/kube-auto-analyzer/master/report_example.png)

## Technical Background - Approach

There's two parts currently implemented by this tool, both wrapped in a ruby gem.  The first element takes the approach of extracting the command lines used to start the relevant containers (e.g. API Server, Scheduler etc) from the API and check them against the relevant sections of the standard.  This is possible via the API server as the spec. of each container contains the command line executed.  At the moment Kubernetes doesn't have any form of API to query it's launch parameters, so this seems like the best approach.

This approach has some limitations but has the advantage of working from anywhere that has access to the API server (so doesn't need deployment on the actual nodes themselves).

In addition to that we've got an agent based approach for checks on the nodes, like file permission and kubelet checks.  The agent can get deployed via the Kubernetes API and then complete it's checks and place the results in the pod log which can then be read in by the script and parsed.  This is a bit on the hacky side but avoids the necessity for any form of network communications from the agent to the running script, which could well be complex.

One of the challenges with scripting these checks is that there are many different Kubernetes distributions, and each one does things differently, so implementing a generic script that covers them all would be tricky.  We're working off kubeadm as a base, but ideally we'll get it working with as many distributions as possible.

### Additional Vulnerability Checks

We're starting to implement checks for common Kubernetes vulnerabilities.  Some of these can be derived from the CIS compliance checks, but in order to get more of a chance of picking them up, we're implementing direct checks as well.

 - Unauthenticated Kubelet check.  Test in place for external access and internal access (via kaa-agent)
 - Unauthenticated API access Check. Test in place for external and internal access.
 - cluster-admin service token.  Test in place for cluster-admin token exposure
 - Container Default containment checks.  Based on Jessie Frazelle's [amicontained](https://github.com/jessfraz/amicontained) We use the agent to check what the default containerization options are for a pod running on the cluster.

## Tested With

 - Kubeadm 1.5,1.6,1.7,1.13 - Works ok  
 - kube-aws - Works ok
 - kismatic - Works ok
 - GCE - Doesn't really work at all.  GCE doesn't run the control plane components as pods, so we can't use this approach.


The switch for adding agent based checking is `--agentChecks` .  If you run using this it will take quite a lot longer to complete, as it pulls/runs the container some times.

## TODO

 - Add RBAC roles so we don't just assume cluster admin for running.
 - Getting to the point where it would be worth some re-factoring to reduce duplication.  specifically abstract common routines like container creation, consistency in variable use etc.