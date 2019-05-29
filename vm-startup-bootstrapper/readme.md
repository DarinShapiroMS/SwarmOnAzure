# **VM Startup Bootstrapper**

This simple C# command line app is placed into the computer startup director on the VM.  Upon auto login, the bootstrapper updates the Swarm Agent config with the number of logical processors on the current instance of the VM.  Since the Swarm Agent has a parameter for how many cores it will use, this exe keeps that up to date in case of changes.

