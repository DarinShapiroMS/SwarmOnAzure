using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace SwarmAgentBootstrapperNet
{
    class Program
    {
        static void Main(string[] args)
        {
            // This utility should run on startup of the Unreal Swarm Agent VM. It will
            // update the swarm config file to set the number of cores
            // to equal those of the host VM.  After setting that value
            // in the config file, it starts the Swarm Agent. 

            

            // Get the number of logical processors
            int vCPU_Count = Environment.ProcessorCount;
            

            int logProcCount = 0;
            foreach (var item in new System.Management.ManagementObjectSearcher("Select * from Win32_ComputerSystem").Get())
            {
                logProcCount+= int.Parse( item["NumberOfLogicalProcessors"].ToString());
            }

            // take the max of both vcpu and logproc
            vCPU_Count = Math.Max(vCPU_Count, logProcCount);
            Console.WriteLine("Number Of Logical Processors: {0}", vCPU_Count);
            Console.ReadLine();

            // ensure we're in the same directory as swarm
            string swarmAgentPath = Environment.CurrentDirectory;
            


            // load dev options
            string devOptionsFilePath = Path.Combine(swarmAgentPath, "SwarmAgent.DeveloperOptions.xml");
            if (!File.Exists(devOptionsFilePath))
                throw new ApplicationException($"Can't find dev options xml file at  '{devOptionsFilePath}'");

            // update element that contains the default processor count
            XElement x = XElement.Load(devOptionsFilePath);
            x.Descendants("RemoteJobsDefaultProcessorCount").First().Value = vCPU_Count.ToString();
            x.Save(devOptionsFilePath);

            // start swarm agent
            var agentFilePath = Path.Combine(swarmAgentPath, "SwarmAgent.exe");
            if (!File.Exists(agentFilePath))
                throw new ApplicationException($"'{agentFilePath}' does not exist. Can't start agent.");

            Console.WriteLine($"Attempting to start agent at '{agentFilePath}'");

            Process process = new Process()
            {
                StartInfo = new System.Diagnostics.ProcessStartInfo
                {
                    WindowStyle = System.Diagnostics.ProcessWindowStyle.Normal,
                    FileName = agentFilePath
                }
            };

            process.Start();
        }

    }
}

