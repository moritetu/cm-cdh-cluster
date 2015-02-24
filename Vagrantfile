#
# Creates some virtual machines which are running a hadoop clouster.
#

# The used box name
$vm_box = "centos65-x86_64"

$attach_disk = proc {|id, vb|
  disk_image = "./disks/#{id.to_s}.dvi"
  storage_attach_command = [
    'storageattach', :id,
    '--storagectl', 'SATA',
    '--port', 1,
    '--device', 0,
    '--type', 'hdd',
    '--medium', disk_image]

  unless File.exist?(disk_image)
    vb.customize ['createhd',
                  '--filename', disk_image,
                  # 15G
                  '--size', 15 * 1024]

    vb.customize storage_attach_command
  else
    vb.customize ['internalcommands', 'sethduuid', disk_image]
    vb.customize storage_attach_command
  end
}

Vagrant.configure("2") do |config|

  # Define base image
  config.vm.box = $vm_box
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"

  # Manage /etc/hosts on host and VMs
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true
  config.hostmanager.ignore_private_ip = false

  # Cluster node parameters
  MASTER_NODE_NUM  = 1
  SLAVE_NODE_NUM   = 3

  # Master nodes
  (1..MASTER_NODE_NUM).each do |i|
    config.vm.define "master#{i}" do |master|
      master.vm.box = $vm_box
      # See https://gist.github.com/leifg/4713995
      #     https://www.virtualbox.org/manual/ch08.html#vboxmanage-createvdi
      master.vm.provider :virtualbox do |v|
        $attach_disk.call("master#{i}", v)
        v.name = "hadoop-master#{i}"
        v.customize ["modifyvm", :id, "--memory", "4096"]
      end
      master.vm.network :private_network, ip: "192.168.10.10#{i}"
      master.vm.hostname = "hadoop1#{i}"
      master.vm.provision :shell, path: "scripts/setup.sh"
      master.vm.provision :hostmanager
      if i == 1
        master.vm.provision :shell, path: "scripts/cloudera-manager-setup.sh"
      end
    end
  end

  # Slave nodes
  (1..SLAVE_NODE_NUM).each do |i|
    config.vm.define "slave#{i}" do |slave|
      slave.vm.box = $vm_box
      slave.vm.provider :virtualbox do |v|
        $attach_disk.call("slave#{i}", v)
        v.name = "hadoop-slave#{i}"
        v.customize ["modifyvm", :id, "--memory", "2048"]
      end
      slave.vm.network :private_network, ip: "192.168.10.2#{sprintf('%02d', i)}"
      slave.vm.hostname = "hadoop2#{i}"
      slave.vm.provision :shell, path: "scripts/setup.sh"
      slave.vm.provision :hostmanager
    end
  end
end
