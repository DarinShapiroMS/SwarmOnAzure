# PowerShell Deployment Scripts
Once executed, a Virtual Machine Scale Set is created in your Azure subscription based upon parameter settings, and the vmss creates and manages the instances of the virtual machines. An important security aspect of this solution is that these instances are deployed into a private virtual network with no public IP or accessibility.  They can only communicate with the Swarm Coordinator over a VPN or Express route connection to your local network.



The three required files
* Deploy.ps1
* template.json
* parameters.json

You will first need to update the relevant parameters in both the parameters.json and deploy.ps1.  Once those are updated, you can execute the deploy.ps1 script with PowerShell. 


### **Prerequisites**
