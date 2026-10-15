using Microsoft.EntityFrameworkCore;
using UniMate.Domain.Entities;

namespace UniMate.Api.Data;

// EF Core's view of the database: each DbSet is a table.
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Job> Jobs => Set<Job>();
    public DbSet<JobApplication> JobApplications => Set<JobApplication>();
    public DbSet<Report> Reports => Set<Report>();

    // Everything EF can't work out from the class and property names.
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(user =>
        {
            user.HasIndex(u => u.Email).IsUnique(); // one account per email
            user.Property(u => u.Role).HasConversion<string>(); // stored as "Client", not 0
        });

        modelBuilder.Entity<Job>(job =>
        {
            job.Property(j => j.Status).HasConversion<string>();
            job.Property(j => j.Budget).HasPrecision(10, 2);

            // Job links to User twice, so EF has to be told which link is which.
            // Restrict: deleting a user must never silently delete their jobs.
            job.HasOne(j => j.Client)
                .WithMany()
                .HasForeignKey(j => j.ClientId)
                .OnDelete(DeleteBehavior.Restrict);

            job.HasOne(j => j.AssignedFreelancer)
                .WithMany()
                .HasForeignKey(j => j.AssignedFreelancerId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<JobApplication>(application =>
        {
            application.Property(a => a.Status).HasConversion<string>();

            // The database itself stops a freelancer applying to the same job twice.
            application.HasIndex(a => new { a.JobId, a.FreelancerId }).IsUnique();

            application.HasOne(a => a.Freelancer)
                .WithMany()
                .HasForeignKey(a => a.FreelancerId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Report>(report =>
        {
            report.Property(r => r.Reason).HasConversion<string>();
            report.Property(r => r.Status).HasConversion<string>();

            report.HasOne(r => r.Reporter)
                .WithMany()
                .HasForeignKey(r => r.ReporterId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Fixed list of categories, inserted by the migration.
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Moving & lifting", IconName = "shippingbox" },
            new Category { Id = 2, Name = "Tutoring", IconName = "book" },
            new Category { Id = 3, Name = "Cleaning", IconName = "sparkles" },
            new Category { Id = 4, Name = "Tech help", IconName = "laptopcomputer" },
            new Category { Id = 5, Name = "Pet care", IconName = "pawprint" },
            new Category { Id = 6, Name = "Errands & delivery", IconName = "bicycle" }
        );
    }
}
