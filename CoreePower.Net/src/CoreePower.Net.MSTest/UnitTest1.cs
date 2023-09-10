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

namespace CoreePower.Net.MSTest
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestTestSampleCmdlet()
        {
            Assembly CoreePowerNet = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(e => e.GetName().Name == "CoreePower.Net");

            var ModuleDir = $@"{Path.GetDirectoryName(CoreePowerNet.Location)}";
            var ModuleDll = CoreePowerNet.Location;
            
            var ModuleManifest = $@"{Path.GetDirectoryName(CoreePowerNet.Location) + Path.DirectorySeparatorChar + CoreePowerNet.GetName().Name}.psd1";

            var ImportModule = string.Format($@"Import-Module ""{ModuleManifest}"" {Environment.NewLine}");
            var Command = string.Format(@"{0} {1} ""{2}""", "Test-SampleCmdlet", "-File", @"foo.cer");

            var script = ImportModule + Command;

            List<PSObject> result = InvokePowershellHost(script);
            var psobjectFirst = (CoreePower.Net.SampleCmdlet.CertificateInformation)(result[0]).BaseObject;

            CoreePower.Net.SampleCmdlet.CertificateInformation certificateInformation = new SampleCmdlet.CertificateInformation();
            certificateInformation.CommonName = "foo";
            certificateInformation.Thumbprint = "foo";

            Assert.AreEqual(certificateInformation.CommonName, psobjectFirst.CommonName);
            Assert.AreEqual(certificateInformation.Thumbprint, psobjectFirst.Thumbprint);

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