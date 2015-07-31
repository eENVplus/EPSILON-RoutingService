using System.IO;
using System.IO.Compression;

namespace BarriersService.App_Start
{
    public class ExtentedMethods
    {
        public byte[] Uncompress(byte[] fi)
        {
            using (MemoryStream inFile = new MemoryStream(fi))
            using (GZipStream Compress = new GZipStream(inFile, CompressionMode.Decompress))
            using (MemoryStream outFile = new MemoryStream())
            {
                Compress.CopyTo(outFile);
                return outFile.ToArray();
            }
        }
    }
}