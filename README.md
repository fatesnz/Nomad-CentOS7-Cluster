# Nomad-CentOS7-Cluster

# Description

This project spins up a nomad cluster of at least 3x nomad machines with 1x nomad
master and 2x nomad clients.

# Vagrantfile

This file describes what vagrant would create. This vagrantfile will create:

- 3x CentOS7 machines using virtualbox with the hostnames being `nomad-a-{i}`, where
  `i` is the number of the machine spun up.
- Expose nomad port `4646` (using port forwarding) so it can be accessed through
  the physical host.
- Create a 172.16.1.0/24 private network with the VMs being attached
  to this network.

To control how many machines to spin up, edit the `for loop` indices:

#This spins up 3 machines number 1,2, and 3

*(1..3)*.each do |i|
  config.vm.define "nomad-a-#{i}" do |n|
    if i == 1
      # Expose the nomad ports
      n.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true
    end
    n.vm.hostname = "nomad-a-#{i}"
    n.vm.network "private_network", ip: "172.16.1.#{i+100}"
  end

# Ansible

The nomad playbook will create the nomad cluster using the VMs and run the
following roles in this order:

- consul: install consul for service discovery and create matching service
- nomad: install nomad and create matching service
- docker: install docker for nomad jobs that uses docker providers
- iptables: this is a customized iptables role that creates dns port forwarding.
  This allows requests to consul dns to hit port 53 on the machines and forward
  to port 8600 where the consul dns interface listens on.
- nomad-jobs: runs a set of nomad jobs. nomad jobs are templated using jinja.

Use the ansible inventory to control which VM to belong to which nomad role (server
or client).

Resources:

Base code is mainly from https://github.com/pgoultiaev/vagrant-centos-nomad-consul-cluster
with modifications to support newer nomad and consul versions and to use different
machine setup.

FW iptables role is based off of Abhishek's fw-iptables role.
