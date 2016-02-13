#
# Creates some virtual machines which are running a hadoop clouster.
#
VAGRANTFILE_API_VERSION = "2"

# The used box name
VM_BOX = "centos65-x86_64"

# The procedure to attach a extra disk.
$attach_disk = proc {|vb|
  disk_image = "./disks/#{vb.name}.dvi"
  unless File.exist?(disk_image)
    vb.customize ['createhd',
      '--filename', disk_image,
      # 15G
      '--size', 15 * 1024]
  end
  vb.customize ['storageattach', vb.name,
    '--storagectl', 'SATA',
    '--port', 1,
    '--device', 0,
    '--type', 'hdd',
    '--medium', disk_image,
  ]
}

ATTACH_DISK = false

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Define base image
  config.vm.box = VM_BOX
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"

  # Manage /etc/hosts on host and VMs
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true
  config.hostmanager.ignore_private_ip = false

  # Chef setting
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  # Common provision  chef_solo
  config.vm.provision :chef_solo do |chef|
    chef.log_level = "info"
    # If the vagrant-berkshelf plugin is disables, use the following paths.
    # https://github.com/berkshelf/vagrant-berkshelf/pull/266
    chef.cookbooks_path = ["./cookbooks", "./site-cookbooks"]
    chef.add_recipe "selinux::disabled"
    chef.add_recipe "yum"
    chef.add_recipe "yum-epel"
    chef.add_recipe "build-essential"
    chef.add_recipe "yum-packages"
    chef.add_recipe "vim"
    chef.add_recipe "git"
    chef.add_recipe "ruby_build"
    chef.add_recipe "ruby_rbenv::system"

    # # Attributes for recipes
    install_ruby_version = "2.3.0"
    chef.json = {
      "ruby_rbenv" => {
        "global" => install_ruby_version,
        "rubies" => [install_ruby_version],
        # https://github.com/fnichol/chef-rbenv/issues/98
        # "gems" => {
        #   install_ruby_version => [
        #     {"name" => "bundler"}
        #   ]
        # }
      }
    }
  end

  # Cluster node parameters
  MASTER_NODE_NUM  = 3
  SLAVE_NODE_NUM   = 3

  # Master nodes
  (1..MASTER_NODE_NUM).each do |i|
    config.vm.define "master#{i}" do |master|
      master.vm.box = VM_BOX
      # See https://gist.github.com/leifg/4713995
      #     https://www.virtualbox.org/manual/ch08.html#vboxmanage-createvdi
      master.vm.provider :virtualbox do |v|
        v.name = "hadoop-master#{i}"
        v.customize ["modifyvm", :id, "--memory", "2048"]
        $attach_disk.call(v) if ATTACH_DISK
      end
      master.vm.network :private_network, ip: "192.168.10.10#{i}"
      master.vm.hostname = "hadoop1#{i}"
      master.vm.provision :shell, path: "scripts/setup.sh"
      master.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = ["./cookbooks", "./site-cookbooks"]
        # Recipes for the master nodes.
      end
      master.vm.provision :hostmanager
      # The only first node is a cloudera manager node.
      if i == 1
        master.vm.provision :shell, path: "scripts/cloudera-manager-setup.sh"
      end
    end
  end

  # Slave nodes
  (1..SLAVE_NODE_NUM).each do |i|
    config.vm.define "slave#{i}" do |slave|
      slave.vm.box = VM_BOX
      slave.vm.provider :virtualbox do |v|
        v.name = "hadoop-slave#{i}"
        v.customize ["modifyvm", :id, "--memory", "2048"]
        $attach_disk.call(v) if ATTACH_DISK
      end
      slave.vm.network :private_network, ip: "192.168.10.2#{sprintf('%02d', i)}"
      slave.vm.hostname = "hadoop2#{i}"
      slave.vm.provision :shell, path: "scripts/setup.sh"
      slave.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = ["./cookbooks", "./site-cookbooks"]
        # Recipes for the slave nodes.
      end
      slave.vm.provision :hostmanager
    end
  end
end
