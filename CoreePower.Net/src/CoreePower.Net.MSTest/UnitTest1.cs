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
        Lazy<Assembly> CoreePowerNetAssembly;


        [TestInitialize]
        public void Setup()
        {
            CoreePowerNetAssembly = new Lazy<Assembly>(() => AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(e => e.GetName().Name == "CoreePower.Net"));
        }

        [TestMethod]
        public void TestMethod1()
        {
            Assembly CoreePowerNet = CoreePowerNetAssembly.Value;

            var ModuleDll = $@"{Path.GetDirectoryName(CoreePowerNet.Location)}";
            var ModuleManifest = $@"{Path.GetDirectoryName(CoreePowerNet.Location) + Path.DirectorySeparatorChar + CoreePowerNet.GetName().Name}.psd1";

            var scriptGen = string.Format($@"Import-Module ""{ModuleManifest}""");
            var scriptGen1 = string.Format(@"{0} {1} ""{2}""", "Test-SampleCmdlet", "-File", @"C:\base\github.com\NaitWatch\SetUpBasic\SetUpBasic Code Signing Certificate.cer");


            var fu = scriptGen + Environment.NewLine + scriptGen1;

            var result = InvokeScript(fu);
            CoreePower.Net.SampleCmdlet.CertificateInformation certificateInformation = new SampleCmdlet.CertificateInformation();
            certificateInformation.CommonName = "CN=SetUpBasic Code Signing Certificate";
            certificateInformation.Thumbprint = "A98D0659C22997E5BED1B0F6168D3D1D533DCF66";

            var resu = (CoreePower.Net.SampleCmdlet.CertificateInformation)(result[0]).BaseObject;

            Assert.AreEqual("foo", resu.CommonName);
            Assert.AreEqual("foo", resu.Thumbprint);

        }


        public List<PSObject> InvokeScript(string script)
        {
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