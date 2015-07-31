using System.Data.Entity;

namespace BarriersService.Models
{
    public partial class MeteoDataEntities : DbContext
    {
        public MeteoDataEntities()
            : base("name=MeteoDataEntities")
        {
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
        }

        public virtual DbSet<IndexMap> IndexMaps { get; set; }

        public virtual DbSet<StudyArea> StudyAreas { get; set; }
    }
}