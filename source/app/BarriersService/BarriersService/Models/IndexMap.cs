using System;

namespace BarriersService.Models
{
    public partial class IndexMap
    {
        public int Id { get; set; }
        public string Area { get; set; }
        public byte[] IndexMapZip { get; set; }
        public byte[] IndexMapZipAscii { get; set; }
        public string Name { get; set; }
        public string Locations { get; set; }
        public Nullable<int> SimulationTime { get; set; }
    }
}