using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Security.Cryptography.X509Certificates;

namespace SetUpBasic.Cmdlet
{
    [Cmdlet(VerbsDiagnostic.Test,"SampleCmdlet")]
    [OutputType(typeof(CertificateInformation))]
    public class SampleCmdlet : PSCmdlet
    {
        public class CertificateInformation
        {
            public string CommonName { get; set; }
            public string Thumbprint { get; set; }
        }

        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public string File { get; set; }


        // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
        protected override void BeginProcessing()
        {
            WriteVerbose("Begin!");
        }

        // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
        protected override void ProcessRecord()
        {
            X509Certificate2 x509 = new X509Certificate2(System.IO.File.ReadAllBytes(File));
            
            var ss = new CertificateInformation { CommonName = x509.Subject, Thumbprint = x509.Thumbprint };
            WriteObject(ss);
        }

        // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
        protected override void EndProcessing()
        {
            WriteVerbose("End!");
        }
    }

}
