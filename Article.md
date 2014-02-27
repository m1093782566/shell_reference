#Bridging the gap between Cloud Foundry and CloudStack:BOSH CPI Support for CloudStack
Cloud Foundry is the leading open source PaaS offering with a fast growing ecosystem and strong enterprise demand. One of its advantages which attracts many developers is its consistent model for deploying and running applications across multiple clouds such as AWS, Vsphere and Openstack. The multi-cloud approach provides developers with more choices and flexibilities. Today, Software Engineering Laboratory of Zhejiang University(ZJU-SEL) and NTT Laboratory Software Innovation Centerwe are glad to announce that Cloud Foundry `V2` has been successfully deployed upon CloudStack with the BOSH CPI Support.

CloudStack is an open source IaaS which is used by a number of service providers to offer public cloud services, and by many companies to provide an on-premises (private) cloud offering, or as part of a hybrid cloud solution. Many enterprises like NTT and BT want to bring Cloud Foundry to CloudStack in an efficient and flexibile way in production environment. Therefore, developing BOSH CloudStack CPI for deploying and operating Cloud Foundry upon CloudStack becomes a logical choice.

This work is powered by ZJU-SEL and NTT, they have been working together to improve this project after merging code repositories of NTT and ZJU-SEL since last November. Thanks to NTT team member [@yudai](https://twitter.com/i_yudai) and ZJU-SEL team member [@zhang](https://github.com/resouer), the main contributors of this project, who had devoted all of their energies to fixing issues and rising to challenges on the CPI work. In addtion, we would like to appreciate the selfless help received from Pivotal Cloud team and [Nic Williams of Engine Yard](http://drnicwilliams.com/).

##Why ZJU-SEL and NTT?
[ZJU-SEL](https://github.com/ZJU-SEL), the biggest software engineering team of Zhejiang University as well as the leading Cloud Computing research institute in China. ZJU-SEL developed BOSH CloudStack CPI for Cloud Foundry `V1` last May, and introduced the CPI work at [Cloud Foundry Conference](http://www.platformcf.com/) in Santa Clara, California last September. ZJU-SEL already had experience running CloudStack advanced zone, and more recently launched a comprehensive PaaS platform based on Cloud Foundry `V1` serving city administrators of HangZhou.

[NTT, the world's leading telecom, has been active in fostering the Cloud Foundry developer and user community in Japan. NTT lab contributes Nise BOSH - a lightweight BOSH emulator for locally compiling, releasing and testing services to Cloud Foundry last April].(more infromations or update?)

The decision to work together was motivated in part because ZJU-SEL intended to move towards Cloud Foundry `V2` and NTT wanted to improve their CPI project so that can be compatible with CloudStack advanced zone(any update?). Vice dean at Software College of Zhejiang University Yang Xiaohu thought highly of this collaboration. "It will be a win-win cooperation, which will build a international platform for learning and working together," Yang said. "I am confident that both sides will benefit much from this project and get all that they want".

##How ZJU-SEL and NTT Collaborate?
Since ZJU-SEL and NTT developed BOSH CloudStack CPI indepently at the very start, there are many differences in the implmentations between ZJU-SEL and NTT. Hence, the first step is to merge code repositories of ZJU-SEL and NTT into a new repository. We chose to create a new [repository](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi) in github [cloudfoundry-community](https://github.com/cloudfoundry-community/) in order to encourage more developers to join us. Fortunately, we all used [Git](https://github.com/) to maintain our codes, thus, it helped save lots of time for us. However, merging and solving conflicts is not a easy task.

There are some crucial aspects in the process of refactoring CPI(check out the [wiki](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi/wiki/Difference-between-ZJU-SEL-and-NTT-implementations) if you are interested in digging more differences between ZJU-SEL and NTT implementations):
* Stemcell Builder
* Create Stemcell
* Basic Zone VS Advanced Zone
* Fog Support

### Stemcell Builder
ZJU-SEL used standard `Ubuntu10.04` ISO file to build stemcells for both MicroBOSH and BOSH. NTT used `Ubuntu10.04` of a backported kernel version due to some compatible problems in their environment. Unfortunately, [`aufs`](http://en.wikipedia.org/wiki/Aufs), which is essential for `warden` in Cloud Foundry `V2`, is missing in the backported kernel. So, we decided to try standard `Ubuntu12.04` as the base OS of stemcells for both MicroBOSH and BOSH after brainstorms. We ultimately found that `Ubuntu12.04` is also compatible with BOSH and Cloud Foundry as long as modifing some lines in cf-release. Of course, it would never have any impact on Cloud Foundry platform itself. What's more, this work proves that Cloud Foundry can also be easily migrated to `Ubuntu14.04` or higher if needed.

### Upload Stemcell
When referring to API call `create_stemcell` in CPI, ZJU-SEL used an extra outside web server as a entrepot when uploading stemcells, which like OpenStack style, but NTT never used an outside web server and took the volume route same as AWS pattern.

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

After a heat discussion in community, we adopted approach B as the current solution for uploading stemcells to bosh director due to approach A is not user-friendly. Meanwhile, we created a new branch for experiment with approach A in case we should need it some day.

### Basic Zone VS Advanced Zone
ZJU-SEL worked in CloudStack advanced zone while NTT developed in CloudStack basic zone since the beginning. ZJU-SEL preferred advanced zone rather than basic zone, because according to their test, basic zone was unable to serve Cloud Founry well unless applying some "tricks" to the network part. In fact, NTT did deploy Cloud Foundry in basic zone by using some "tricks", for instance, deploying a seprated BOSH dns node and so on. However, we all agreed that it's unconvenient to work in basic zone especially when we need to redeploy some components such as `router`. Ultimately, we reached an agreement that adding an option based on network type to switch the zone type between basic and advanced.

### Fog Support
Both ZJU-SEL and NTT invoked fog gem to send API requests to CloudStack engine. Nevertheless, APIs of official fog gem are too old to supporting BOSH Cloudstack CPI developing even right now! ZJU-SEL built a local fog gem which supplemented the missing APIs while NTT added a fog patch with missing APIs in CPI project to work around for the moment. We already have sent a PR to [fog](https://github.com/fog/fog) and are waiting for it to be merged.

When refactoring work finished, we started a month-long heavy test. Once a bug was found, the bug finder would open an issue and describe detailed informations about it. Then all of the developers will receive the message about this bug via mail list. Any commit to the code repository would be submitted in the form of pull request and the repository owners would review the set of changes, discuss potential modifications, and even push follow-up commits if necessary. Only if the PR passed CI and BAT can it be merged. Simply put, we followed the workflow of other Cloud Foundry repositories in github sucn as cf-release and bosh. In this way, we controled the history of the new repository and no potential dangerous code could be maxed in.

##Current Status
* Finished development and test work.
* Support both basic zone and advanced zone for CloudStack.
* Tested on CloudStack `4.0.0` and `4.2.0` with KVM hypervisor.
* Successfully deployed Cloudfoundry `V2` and had applications running.
* Support both `Ubuntu10.04` and `Ubuntu12.04` stemcells.
* Support `Ubuntu14.04` stemcell is in the TODO list.
* Maintained in github and opened for all users.

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

The inception server must have a security group which opens the TCP port `25889`, which is used by the temporary BOSH Registry launched by BOSH Deployer. In advanced zone, you need to configure the firewall rule of inception server which opens the TCP port `25889` for the same reason.

You also need to create one or more security groups or firewall rules for VMs created by your BOSH instance. We recommend that you create a security group or firewall rule which opnens all the TCP and UDP ports for testing. When in production environment, we strongly suggest setting more tight security group or firewall rules.


#### Boot a Ubuntu Server

We recommend Ubuntu `12.04 64bit` or later for your inception server. For those who use `Ubuntu 12.10` or later we recommand to select `Ubuntu 10.04` or later for the `OS type` while creating instance from ISO file or registering VM templates.

### More Steps
You may find more detailed guide step by step conncerning on deploying Cloud Foundry on CloudStack
[here](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi/blob/master/README.md).
In fact, the remaining steps are very straightforward and similar with other deployment methods such as AWS, Vsphere and Openstack.

## Facts and Lessons Learned

Generally speaking, this is a successful cross-national collaboration which benefits both ZJU-SEL and NTT a lot. ZJU-SEL have learnt the strict work style and devoted work attitude from NTT and got a more robust BOSH which is compatiable with Cloud Foudnry `V2`.[NTT?]
The most precious assets we get from this cooperation maybe the experience in how to perform transnational cooperation effectively and how to have the aid of community's power.

With the help of BOSH(on the preimise of solid preparation), the whole deployment took hours to finish. During deployment, the most time consuming part was the preparations. In other words, with preparations done, you may just need to wait hours to have a Cloud Foundry PaaS on top of CloudStack infrastructure in production environment.

Apart from automatical deployment, BOSH provides abundant command line interfaces to manage the whole lifecycle of your release, stemcell, VM and so on. As a result, operating large scale distributed services is a joy rather than a headache task any longer.

Finally, it proved that Cloud Foundry preserves consistent model for deploying and running applications across multiple clouds. This is a critical requirement for a successful PaaS which helps Cloud Foundry become more and more popular.

## Join Us

Questions about the BOSH CloudStack CPI can be directed to BOSH Google Groups. Of course, please open an issue or send a pull request if you want to improve this [project](https://github.com/cloudfoundry-community/bosh-cloudstack-cpi).
