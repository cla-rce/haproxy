#
# Cookbook Name:: haproxy
# Recipe:: rdp
#
# Copyright 2012, University of Minnesota
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

pool_members = search("node", "role:#{node['haproxy']['app_server_role']}") || []

# load balancer may be in the pool
pool_members << node if node.run_list.roles.include?(node['haproxy']['app_server_role'])

package "haproxy" do
  action :install
end

cookbook_file "/etc/default/haproxy" do
  source "haproxy-default"
  owner "root"
  group "root"
  mode 00644
end

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy-rdp.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables :pool_members => pool_members.uniq
  notifies :reload, "service[haproxy]"
end
