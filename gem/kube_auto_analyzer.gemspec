# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kube_auto_analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = "kube_auto_analyzer"
  spec.version       = KubeAutoAnalyzer::VERSION
  spec.authors       = ["Rory McCune"]
  spec.email         = ["rory.mccune@nccgroup.trust"]
  spec.summary       = %q{A Gem which provides a script and class analyze the security of a Kubernetes cluster.}
  spec.description   = %q{This is a gem used to help when conducting a security analysis of a Kubernetes cluster in-line with the requirements of the CIS Benchmark.}
  spec.homepage      = "https://github.com/nccgroup/kube-auto-analyzer"
  spec.license       = "AGPL"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 0"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_runtime_dependency "kubeclient", ">= 2.4.0"
  spec.add_runtime_dependency "chartkick", ">= 2.2.4"
end