using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.Management.Automation;
using System;
using System.Linq;
using System.Management.Automation.Runspaces;
using System.Diagnostics;
using System.Reflection;
using System.CodeDom;
using System.IO;
using System.Collections.ObjectModel;

namespace CoreePower.Net.SoundCloudExplode.MSTest
{
    [TestClass]
    public class UnitTest1
    {
        public UnitTest1()
        {
            var ref1 = typeof(SaveTrackCmdlet);
        }

        [TestMethod]
        public void TestSaveTrack()
        {
            Assembly assembly = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(e => e.GetName().Name == "CoreePower.Net.SoundCloudExplode");

            var ModuleDir = $@"{Path.GetDirectoryName(assembly.Location)}";
            var ModuleDll = assembly.Location;

            var ModuleManifest = $@"{Path.GetDirectoryName(assembly.Location) + Path.DirectorySeparatorChar + assembly.GetName().Name}.psd1";

            var ImportModule = string.Format($@"Import-Module ""{ModuleManifest}"" {Environment.NewLine}");
            var Command = string.Format(@"{0} {1} ""{2}""", "Save-Track", "-TrackUrl", @"https://soundcloud.com/kevin-kiner/ahsoka-end-credits-from-ahsoka");

            var script = ImportModule + Command;

            List<PSObject> result = InvokePowershellHost(script);
        }

        public List<PSObject> InvokePowershellHost(string script)
        {
            Debug.WriteLine(script);
            Collection<PSObject> InvokeResult;

            using (PowerShell powerShell = PowerShell.Create())
            {
                powerShell.RunspacePool = RunspaceFactory.CreateRunspacePool();
                powerShell.RunspacePool.Open();
                powerShell.AddScript(script);
                InvokeResult = powerShell.Invoke();
            }
            return InvokeResult.ToList();
        }
    }
}