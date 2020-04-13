oneGB = 1 * 1000 * 1000 # in KB
 
$testbed = Proc.new do
  {
    "name" => "testbed-test",
    "version" => 3,
    "esx" => (0..1).map do | idx |
      {
        "name" => "esx.#{idx}",
        "vc" => "vc.0",
        "dc" => "vcqaDC",
        "clusterName" => "cluster0",
        "style" => "fullInstall",
        "disks" => [ 15 * oneGB, 15 * oneGB ],
        "guestOSlist" => [         
          {
            "vmName" => "centos-vm.#{idx}",
            "ovfuri" => NimbusUtils.get_absolute_ovf("CentOS6_x64_2GB/CentOS6_x64_2GB.ovf")
          }
        ]
      }
    end,
 
    "vcs" => [
      {
        "name" => "vc.0",
        "type" => "vcva",
        "dcName" => ["vcqaDC"],
        "clusters" => [
          {
            "name" => "cluster0",
            "dc" => "vcqaDC",
            "enableDrs" => true,
            "enableHA" => true,
          },
        ]
      }
    ],
 
    "beforePostBoot" => Proc.new do |runId, testbedSpec, vmList, catApi, logDir|
    end,
    "postBoot" => Proc.new do |runId, testbedSpec, vmList, catApi, logDir|
    end
  }
end
