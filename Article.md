#Bridging the gap between Cloud Foundry and CloudStack:BOSH CPI Support for CloudStack
Cloud Foundry is the leading open source PaaS offering with a fast growing ecosystem and strong enterprise demand. One of its advantages which attracts many developers is its consistent model for deploying and running applications across multiple clouds such as AWS, VSphere and Openstack. The approach provides cloud adopters with more choices and flexibilities. Today, College of Software Technology, Zhejiang University, China (ZJU-CST) and NTT Laboratory Software Innovation Centerwe are glad to announce that we have successfully developed the BOSH CloudStack CPI, which automates the deployment and management process of Cloud Foundry V2 upon CloudStack.

CloudStack is an open source IaaS which is used by a number of service providers to offer public cloud services, and by many companies to provide an on-premises (private) cloud offering, or as part of a hybrid cloud solution. Many enterprises like NTT and BT want to bring Cloud Foundry to CloudStack in an efficient and flexibile way in production environment. Therefore, developing BOSH CloudStack CPI for deploying and operating Cloud Foundry upon CloudStack becomes a logical choice.

This work is powered by ZJU-CST and NTT, we have been working together since last November. Thanks to NTT team member [@yudai](https://twitter.com/i_yudai) and ZJU-CST team member [@zhang](https://github.com/resouer), the main contributors of this project, who had devoted much of their energies to fixing issues and rising to challenges on the CPI work. In addtion, we would like to appreciate the selfless help received from Pivotal Cloud team and [Nic Williams](http://drnicwilliams.com/).

##Why ZJU-CST and NTT?
[ZJU-CST](https://github.com/ZJU-SEL) is the biggest software engineering team of Zhejiang University as well as the leading Cloud Computing research institute in China. ZJU-CST started R&D work on Cloud Foundry and CloudStack about 3 years ago, and more recently launched a comprehensive PaaS platform based on Cloud Foundry `V1` serving City Management Department of Hangzhou China. ZJU-CST released BOSH CloudStack CPI for Cloud Foundry V1 last May, and introduced the CPI work at PlatformCF 2013 in Santa Clara, California last September.

[NTT, the world's leading telecom, has been active in fostering the Cloud Foundry developer and user community in Japan. NTT lab contributes Nise BOSH - a lightweight BOSH emulator for locally compiling, releasing and testing services to Cloud Foundry last April].(more infromations or update?)

The decision to work together was motivated in part because ZJU-CST intended to upgrade the CPI  to support Cloud Foundry V2 and NTT wanted to improve their independently developed BOSH CloudStack CPI project so that can be compatible with CloudStack advanced zone. 

Xiaohu Yang, Vice dean of College of Software Technology, Zhejiang University, thought highly of this international collaboration. "It will be a win-win cooperation, open source projects such as Cloud Foundry can serve as an international platform for education and researching".

##Technical Details
Since ZJU-CST and NTT developed BOSH CloudStack CPI indecently at the beginning, there are many differences in the implementation. Hence, the first step is to merge code repositories of ZJU-CST and NTT into a new repository. We chose to create a new repository in github cloudfoundry-community in order to encourage more developers to join us.

There are some crucial aspects in the process of refactoring CPI(check out the [wiki](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi/wiki/Difference-between-ZJU-SEL-and-NTT-implementations) if you are interested in digging more differences between ZJU-CST and NTT implementations):

* Stemcell Builder
* Create Stemcell
* Basic Zone VS Advanced Zone
* Fog Support

### Stemcell Builder
ZJU-CST used standard Ubuntu10.04 ISO file to build stemcells for both MicroBOSH and BOSH. NTT used Ubuntu10.04 of a backported kernel version due to some compatible problems in their environment. Unfortunately, aufs, which is essential for warden in Cloud Foundry V2, is missing in the backported kernel. So, we decided to try standard Ubuntu12.04 as the base OS of stemcells for both MicroBOSH and BOSH after brainstorms. We found that, with a minor patch of cf-release, Ubuntu12.04 is compatible with BOSH and Cloud Foundry. The patch only modifies the deployment process of Cloud Foundry, so it does not impact the Cloud Foundry platform itself.

### Upload Stemcell
When referring to API call create_stemcell in CPI, ZJU-CST used an extra web server as a entrepot when uploading stemcells, which follows the OpenStack style, but NTT didn’t used an extra web server and took the volume route same as AWS pattern.

Implementation [A]:

* Similar to the OpenStack CPI
* Requires no inception server
* Requires a web server to save qcow2 files and expose them at HTTP for CloudStack
* [Client] --> (SSH upload) --> [WebServer] --> (HTTP) --> [CloudStack]
* The API call can't receive image files directly, it downloads image files from given URLs
The WebServer is necessary because CloudStack can not directly receive image data from inception server.

Implementation [B]:

* Same process as that of the AWS CPI
* Requires an inception server to create a bootstrap Micro BOSH stemcell
* Copies (using `dd`) a raw stemcell image to a volume attached to the inception server
* Creates a template from a snapshot of the volume

Both implementations have cons and pros.

[A] user have to setup a web server somewhere, however users can bootstrap MicroBOSH from the outside of CloudStack.

[B] an inception server is always required, however users don't have to setup a web server.

After a heated discussion in the open source community, we adopted approach B as the current solution for uploading stemcells to bosh director due to approach A is not user-friendly. Meanwhile, we created a new branch for experiment with approach.

### Basic Zone VS Advanced Zone

Before the collaboration between ZJU-CST and NTT, ZJU-CST worked in CloudStack advanced zone while NTT developed in CloudStack basic zone. ZJU-CST preferred advanced zone because according to our test, basic zone was unable to support Cloud Foundry without applying some "tricks" during the network configuration process. On the other hand, NTT did deploy Cloud Foundry in basic zone by using some "tricks", for instance, deploying a separated BOSH DNS node and so on. However, we all agreed that it's inconvenient to work in basic zone especially when we need to redeploy some components such as router. Finally, we reached an agreement to support both network types and add an option to switch between them.

### Fog Support

Both ZJU-CST and NTT invoked fog gem to send API requests to CloudStack engine. However, APIs of the official fog gem are not rich enough to supporting BOSH Cloudstack CPI. ZJU-CST built a local fog gem which added the missing APIs while NTT made a fog patch with missing APIs in CPI project to work around for the moment. We already have sent a PR to fog and are waiting for it to be merged.

When refactoring work finished, we started a month-long heavy test. Once a bug was found, the bug finder would open an issue and describe detailed informations about it. Then all of the developers will receive the message about this bug via mail list. Any commit to the code repository would be submitted in the form of pull request and the repository owners would review the set of changes, discuss potential modifications, and even push follow-up commits if necessary. Only if the PR passed CI and BAT can it be merged. Simply put, we followed the workflow of other Cloud Foundry repositories in github such as cf-release and bosh. In this way, we controlled the history of the new repository and no potential dangerous code could be maxed in.

##Current Status
* Finished development and test work.
* Support both basic zone and advanced zone for CloudStack.
* Tested on CloudStack `4.0.0` and `4.2.0` with KVM hypervisor.
* Successfully deployed Cloudfoundry `V2` and had applications running.
* Support both `Ubuntu10.04` and `Ubuntu12.04` stemcells.
* Support `Ubuntu14.04` stemcell is in the TODO list.
* Open sourced and maintained in github.

## How to Deploy Cloud Foundry on CloudStack

### Steps
* Create Inception Server
* Bootstrap Micro BOSH
* Deploy Cloud Foundry
* Setup Full BOSH (Optional)


### Create Inception Server
You need a VM on the CloudStack domain where you install a BOSH instance using this CPI. This VM is so-called "inception" server. You will install BOSH CLI and BOSH Deployer gems on this server and run all operations with them.

#### Why do I need an inception server?
The CloudStack CPI creates stemcells, which are VM templates, by copying pre-composed disk images to data volumes which automatically attached by BOSH Deployer. This procedure is same as that of the AWS CPI and requires that the VM where BOSH Deployer works is running on the same domain where you want to deploy your BOSH instance.


#### Create Security Groups or Firewall Rules
You also need to create one or more security groups or firewall rules for VMs created by your BOSH instance. We recommend that you create a security group or firewall rule which opens all the TCP and UDP ports for testing. When in production environment, we strongly suggest setting more tight security group or firewall rules.


#### Boot an Ubuntu Server
We recommend Ubuntu 12.04 64bit or later for your inception server. For those who use Ubuntu 12.10 or later we recommend to select Ubuntu 10.04 or later for the OS type while creating instance from ISO file or registering VM templates.

### More Steps
You may find more detailed guide step by step concerning on deploying Cloud Foundry on CloudStack
[here](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi/blob/master/README.md).
In fact, the remaining steps are very straightforward and similar with other deployment methods such as AWS, Vsphere and Openstack.

## Facts and Lessons Learned

This is a successful international collaboration which benefits both ZJU-CST and NTT a lot. ZJU-CST have learnt the strict work style and devoted work attitude from NTT and got a more robust BOSH which is compatible with Cloud Foundry V2.[NTT?] The most precious assets we get from this cooperation maybe the experience in how to perform international cooperation effectively and how to reach out to the community if help is needed.

## Join Us

Questions about the BOSH CloudStack CPI can be directed to BOSH Google Groups. Of course, please open an issue or send a pull request if you want to improve this [project](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi).
