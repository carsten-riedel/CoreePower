using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace SetUpBasic.Cmdlet
{
    [Cmdlet(VerbsCommunications.Read, "SubCertificateFromFile")]
    [OutputType(typeof(CertificateInformation))]
    public class SubCertificateFromFile : PSCmdlet
    {
        public class CertificateInformation
        {
            public string CommonName { get; set; }
            public string Thumbprint { get; set; }
        }

        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public string File { get; set; } = null;

        [Parameter(Mandatory = false, Position = 1, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public string Password { get; set; } = null;

        // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
        protected override void BeginProcessing()
        {
            WriteVerbose("Begin!");
        }

        // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
        protected override void ProcessRecord()
        {
            X509Certificate2 x509=null;
            try
            {
                if (Password != null)
                {
                    x509 = new X509Certificate2(System.IO.File.ReadAllBytes(File), Password);
                }
                else
                {
                    x509 = new X509Certificate2(System.IO.File.ReadAllBytes(File));
                }
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(ex, "SubCertificateFromFile", ErrorCategory.ReadError, File));
            }

            

            /*
            X509Certificate2 ss = new X509Certificate2()
            var retval = new CertificateInformation { 
                CommonName = x509.Subject,
                Thumbprint = x509.Thumbprint,
                
            };
            */
            WriteObject(x509);

        }

        // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
        protected override void EndProcessing()
        {
            WriteVerbose("End!");
        }
    }
}
