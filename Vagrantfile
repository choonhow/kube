######################################
# Other images available
# bento/ubuntu-16.04
# ubuntu/xenial64
# bento/centos-7.6
# centos/7
######################################

domain   = 'vg'

nodes = [
  { :hostname => 'k8s-m',    :ip => '192.168.10.80', :ram => 4096, :port => 10080, :vmhttp => 7080, :vmhttps => 7443, :os =>'ubuntu16', :image => 'bento/ubuntu-16.04'},
  { :hostname => 'k8s-n1',   :ip => '192.168.10.81', :ram => 2048, :port => 10081, :vmhttp => 7081, :vmhttps => 7444, :os =>'ubuntu16', :image => 'bento/ubuntu-16.04'},
  { :hostname => 'k8s-n2',   :ip => '192.168.10.82', :ram => 2048, :port => 10081, :vmhttp => 7082, :vmhttps => 7445, :os =>'ubuntu16', :image => 'bento/ubuntu-16.04'},
  { :hostname => 'jenkins',  :ip => '192.168.10.88', :ram => 2048, :port => 10088, :vmhttp => 7088, :vmhttps => 7448, :os =>'ubuntu16', :image => 'bento/ubuntu-16.04'}
]

$script = <<SCRIPT

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      name = node[:hostname]
      
      nodeconfig.vm.box = node[:image]
      nodeconfig.vm.hostname = node[:hostname] + ".box"
      nodeconfig.vm.network :private_network, ip: node[:ip]
      nodeconfig.vm.network :forwarded_port, guest: 22, host: node[:port], id: "ssh"

      memory = node[:ram] ? node[:ram] : 256;
      nodeconfig.vm.provider :virtualbox do |vb|
        vb.name = name+"."+domain
        vb.customize [
          "modifyvm", :id,
          "--memory", memory.to_s,
          "--cpus", "2"
        ]
      end
      nodeconfig.vm.provision "file", source: "hosts", destination: "hosts"
      nodeconfig.vm.provision "file", source: "~/.vagrant.d/insecure_private_key", destination: "/home/vagrant/.ssh/id_rsa"
      
      #nodeconfig.vm.provision "shell", inline: $script
      nodeconfig.vm.provision "shell", path: "scripts/setup-vagrant-"+node[:os]+".sh"
      nodeconfig.vm.provision "shell", path: "scripts/setup-common-"+node[:os]+".sh"	  

#Master node(s)
#TCP Inbound 6443
#TCP Inbound 2379–2380
#TCP Inbound 10250
#TCP Inbound 10251
#TCP Inbound 10252

#Worker node(s)
#TCP Inbound -10250
#TCP Inbound 30000–32767

      if name == "k8s-m" 
        nodeconfig.vm.network :forwarded_port, host: 8001, guest: 8001
        nodeconfig.vm.network :forwarded_port, host: 6443, guest: 6443
        nodeconfig.vm.network :forwarded_port, host: 10250, guest: 10250
        nodeconfig.vm.network :forwarded_port, host: 10251, guest: 10251
        nodeconfig.vm.network :forwarded_port, host: node[:vmhttp], guest: 8080
        nodeconfig.vm.network :forwarded_port, host: node[:vmhttps], guest: 443
      end
      if name == "k8s-n1" || name == "k8s-n1"
        #nodeconfig.vm.network :forwarded_port, host: 10250, guest: 10250		
        nodeconfig.vm.network :forwarded_port, host: node[:vmhttp], guest: 8080
        nodeconfig.vm.network :forwarded_port, host: node[:vmhttps], guest: 443
      end
      if name == "jenkins" 
        nodeconfig.vm.network :forwarded_port, host: node[:vmhttp], guest: 8000        
      end
      
      # disable/enable the default share
      nodeconfig.vm.synced_folder ".", "/vagrant", disabled: false
      
    end
  end
end
