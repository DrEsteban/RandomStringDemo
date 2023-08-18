using Microsoft.EntityFrameworkCore;

namespace StringFetcher.Data;

public class StringsDbContext : DbContext
{
    public StringsDbContext(DbContextOptions<StringsDbContext> options, IConfiguration configuration) : base(options) 
    {
        if (configuration.GetValue<bool>("RunMigrations"))
        {
            // This is weird and bad, but hey it's a demo :)
            this.Database.Migrate();
        }
    }

    public DbSet<StringEntry> StringsTable { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Seed data
        var entries = Enumerable.Range(1, 50).Select(i => new StringEntry(i, $"This is random string #{i}"));
        modelBuilder.Entity<StringEntry>().HasData(entries);
    }
}
