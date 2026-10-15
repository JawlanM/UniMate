using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

public class Job
{
    public Guid Id { get; set; }

    // The client who posted the job.
    public Guid ClientId { get; set; }
    public User Client { get; set; } = null!;

    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;

    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Budget { get; set; }
    public string Suburb { get; set; } = string.Empty;
    public DateTimeOffset ScheduledAt { get; set; }

    public JobStatus Status { get; set; } = JobStatus.Open;

    // Set when the client accepts an application. A job has at most one freelancer.
    public Guid? AssignedFreelancerId { get; set; }
    public User? AssignedFreelancer { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }

    public List<JobApplication> Applications { get; set; } = new();

    // Status rules. The endpoints ask these before changing anything,
    // and the unit tests call them directly without a database.
    public bool CanApply() => Status == JobStatus.Open;

    public bool HasApplicationFrom(Guid freelancerId) =>
        Applications.Any(a => a.FreelancerId == freelancerId);

    public bool CanAccept(JobApplication application) =>
        Status == JobStatus.Open
        && application.JobId == Id
        && application.Status == ApplicationStatus.Pending;

    public bool CanComplete() => Status == JobStatus.Assigned;

    public bool CanCancel() => Status == JobStatus.Open;


    // Open to Assigned. The chosen application is accepted, every other pending one is rejected.
    public void Accept(JobApplication chosen)
    {
        if (!CanAccept(chosen)) throw new InvalidOperationException("This application can't be accepted.");

        Status = JobStatus.Assigned;
        AssignedFreelancerId = chosen.FreelancerId;
        foreach (var application in Applications.Where(a => a.Status == ApplicationStatus.Pending))
        {
            application.Status = application.Id == chosen.Id ? ApplicationStatus.Accepted : ApplicationStatus.Rejected;
        }
    }


    // Assigned to Completed
    public void Complete(DateTimeOffset now)
    {
        if (!CanComplete()) throw new InvalidOperationException("Only an assigned job can be completed.");

        Status = JobStatus.Completed;
        CompletedAt = now;
    }

    // Open to Cancelled. Anyone still waiting gets rejected.
    public void Cancel()
    {
        if (!CanCancel()) throw new InvalidOperationException("Only an open job can be cancelled.");

        Status = JobStatus.Cancelled;
        foreach (var application in Applications.Where(a => a.Status == ApplicationStatus.Pending))
        {
            application.Status = ApplicationStatus.Rejected;
        }
    }




}
