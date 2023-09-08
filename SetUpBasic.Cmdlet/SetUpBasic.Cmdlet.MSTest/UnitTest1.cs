using System.Collections.Generic;
using System.Management.Automation;
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SetUpBasic.Cmdlet.MSTest
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {

        var ass = System.Reflection.Assembly.GetAssembly(typeof(SetUpBasic.Cmdlet.SampleCmdlet));

        var scriptGen = string.Format(@"Import-Module ""{0}""", ass.Location );
        var scriptGen1 = string.Format(@"{0} {1} ""{2}""", "Test-SampleCmdlet", "-File", @"C:\base\github.com\NaitWatch\SetUpBasic\SetUpBasic Code Signing Certificate.cer");
        var fu = scriptGen + Environment.NewLine + scriptGen1;
            
            string script1 = string.Format(@"
            Import-Module """+ ass.Location + @"""
            Test-SampleCmdlet -File ""x""
            
        ");
            var result = InvokeScript(fu);
            SetUpBasic.Cmdlet.SampleCmdlet.CertificateInformation certificateInformation = new SampleCmdlet.CertificateInformation();
            certificateInformation.CommonName = "CN=SetUpBasic Code Signing Certificate";
            certificateInformation.Thumbprint = "A98D0659C22997E5BED1B0F6168D3D1D533DCF66";
            
            var resu =(SetUpBasic.Cmdlet.SampleCmdlet.CertificateInformation)((PSObject)result[0]).BaseObject;
   
        }

        public List<object> InvokeScript(string script)
        {
            List<object> pSDataStreams = new List<object>();
            using (PowerShell powerShell = PowerShell.Create())
            {
                powerShell.Streams.Information.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Error.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Debug.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Progress.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Verbose.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                powerShell.Streams.Warning.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                
                powerShell.AddScript(script);

                /*
                foreach (PSObject result in powerShell.Invoke())
                {
                    Console.WriteLine(
                                "{0,-20} {1}",
                                result.Members["ProcessName"].Value,
                                result.Members["HandleCount"].Value);
                }
                */

                // powerShell.Streams.Information.d
                using (var outputCollection = new PSDataCollection<PSObject>())
                {
                    outputCollection.DataAdding += (sender, e) => { pSDataStreams.Add(e.ItemAdded); };
                    powerShell.Invoke();
                }
            }
            return pSDataStreams;
        }
    }
}