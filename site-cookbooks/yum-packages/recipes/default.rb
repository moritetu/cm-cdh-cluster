#
# Cookbook Name:: site-cookbooks/yum-packages
# Recipe:: default
#
# Copyright (C) 2015 moritoru81
#
# All rights reserved - Do Not Redistribute
#
%w[openssl openssl-devel sqlite sqlite-devel readline-devel].each do |pkg|
  package pkg do
    name "yum-packages-#{pkg}"
    action :install
  end
end
