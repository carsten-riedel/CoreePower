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

            var ModuleManifest = $@"{Path.GetDirectoryName(CoreePowerNet.Location) + Path.DirectorySeparatorChar + CoreePowerNet.GetName().Name}.psd1";

            var scriptGen = string.Format(@"Import-Module ""{0}""", ModuleManifest);
            var scriptGen1 = string.Format(@"{0} {1} ""{2}""", "Test-SampleCmdlet", "-File", @"C:\base\github.com\NaitWatch\SetUpBasic\SetUpBasic Code Signing Certificate.cer");
            var fu = scriptGen + Environment.NewLine + scriptGen1;


            var result = InvokeScript(fu);
            CoreePower.Net.SampleCmdlet.CertificateInformation certificateInformation = new SampleCmdlet.CertificateInformation();
            certificateInformation.CommonName = "CN=SetUpBasic Code Signing Certificate";
            certificateInformation.Thumbprint = "A98D0659C22997E5BED1B0F6168D3D1D533DCF66";

            var resu = (CoreePower.Net.SampleCmdlet.CertificateInformation)((PSObject)result[0]).BaseObject;

        }

        [TestMethod]
        public void TestMethod2()
        {

            string namespaceName = "CoreePower.Net";
            var ass = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(e => e.GetName().Name ==namespaceName);


            var scriptGen = string.Format(@"Import-Module ""{0}""", ass.Location);
            var scriptGen1 = string.Format(@"{0} {1} ""{2}""", "Test-SampleCmdlet", "-File", @"C:\base\github.com\NaitWatch\SetUpBasic\SetUpBasic Code Signing Certificate.cer");
            var fu = scriptGen + Environment.NewLine + scriptGen1;

            string script1 = string.Format(@"
            Import-Module """+ ass.Location + @"""
            Test-SampleCmdlet -File ""x""
            
        ");
            var result = InvokeScript(fu);
            CoreePower.Net.SampleCmdlet.CertificateInformation certificateInformation = new SampleCmdlet.CertificateInformation();
            certificateInformation.CommonName = "CN=SetUpBasic Code Signing Certificate";
            certificateInformation.Thumbprint = "A98D0659C22997E5BED1B0F6168D3D1D533DCF66";

            var resu = (CoreePower.Net.SampleCmdlet.CertificateInformation)((PSObject)result[0]).BaseObject;

        }


        public List<object> InvokeScript(string script)
        {
            List<object> pSDataStreams = new List<object>();
            using (PowerShell powerShell = PowerShell.Create())
            {
                powerShell.RunspacePool = RunspaceFactory.CreateRunspacePool();
                powerShell.RunspacePool.Open();
                powerShell.Streams.Information.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Error.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Debug.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Progress.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Verbose.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Warning.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };

                powerShell.AddScript(script);

                
                foreach (PSObject result in powerShell.Invoke())
                {
                    Debug.WriteLine(
                                "{0,-20} {1}",
                                result.Members["CommonName"].Value,
                                result.Members["Thumbprint"].Value);
                }
               

                // powerShell.Streams.Information.d
                using (var outputCollection = new PSDataCollection<PSObject>())
                {
                    outputCollection.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                    powerShell.Invoke(null, outputCollection);
                }
            }
            return pSDataStreams;
        }
    }
}