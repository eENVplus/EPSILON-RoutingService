namespace BarriersService.Models
{
    public partial class StudyArea
    {
        public int Id { get; set; }
        public string Area { get; set; }
        public string AreaName { get; set; }
        public string Link { get; set; }
        public int ncols { get; set; }
        public int nrows { get; set; }
        public int xllcorner { get; set; }
        public int yllcorner { get; set; }
        public int cellsize { get; set; }
        public int NODATA_value { get; set; }
    }
}