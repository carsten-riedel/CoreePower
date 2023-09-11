using SoundCloudExplode;
using System;
using System.IO;
using System.Management.Automation;


namespace CoreePower.Net
{
    [Cmdlet(VerbsData.Save, "Track")]
    public class SaveTrackCmdlet : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public string TrackUrl { get; set; }


        // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
        protected override void BeginProcessing()
        {
            WriteVerbose("Begin!");
        }

        // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
        protected override void ProcessRecord()
        {
            try
            {
                var soundcloud = new SoundCloudClient();
                var TrackData = soundcloud.Tracks.GetAsync(TrackUrl).Result;
                var trackTitle = string.Join("_", TrackData.Title.Split(Path.GetInvalidFileNameChars()));
                var downloadfile = $@"{System.Environment.GetFolderPath(System.Environment.SpecialFolder.MyMusic)}\Download\{trackTitle}.mp3";
                soundcloud.DownloadAsync(TrackData, downloadfile).AsTask().Wait();
                WriteObject(downloadfile);
            }
            catch (System.Exception e)
            {
                var errorRecord = new ErrorRecord(
                    e,                                          // Actual exception caught
                    $"{e.GetType().Name}",                       // An ErrorID, you can also set a custom string here
                    ErrorCategory.NotSpecified,                  // A category that makes sense for your exception
                    null                                         // The object this exception applies to, if applicable
                );

                errorRecord.ErrorDetails = new ErrorDetails($"Failed due to: {e.Message}");

                WriteError(errorRecord);
            }
        }

        // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
        protected override void EndProcessing()
        {
            WriteVerbose("End!");
        }
    }
}