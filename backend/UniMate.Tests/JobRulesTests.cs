using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Tests;

// Tests for the status rules on Job and JobApplication. No database or HTTP needed.
public class JobRulesTests
{
    // An open job with one pending application from each freelancer id given.
    private static Job OpenJobWithApplicants(params Guid[] freelancerIds)
    {
        var job = new Job { Id = Guid.NewGuid(), Status = JobStatus.Open };
        foreach (var freelancerId in freelancerIds)
        {
            job.Applications.Add(new JobApplication { Id = Guid.NewGuid(), JobId = job.Id, FreelancerId = freelancerId });
        }
        return job;
    }

    [Fact]
    public void Accept_AssignsJob_AndRejectsOtherPendingApplications()
    {
        var job = OpenJobWithApplicants(Guid.NewGuid(), Guid.NewGuid());
        var chosen = job.Applications[0];
        var other = job.Applications[1];

        job.Accept(chosen);

        Assert.Equal(JobStatus.Assigned, job.Status);
        Assert.Equal(chosen.FreelancerId, job.AssignedFreelancerId);
        Assert.Equal(ApplicationStatus.Accepted, chosen.Status);
        Assert.Equal(ApplicationStatus.Rejected, other.Status);
    }

    [Fact]
    public void Accept_LeavesWithdrawnApplicationsAlone()
    {
        var job = OpenJobWithApplicants(Guid.NewGuid(), Guid.NewGuid());
        var withdrawn = job.Applications[1];
        withdrawn.Withdraw();

        job.Accept(job.Applications[0]);

        Assert.Equal(ApplicationStatus.Withdrawn, withdrawn.Status);
    }

    [Fact]
    public void CanAccept_IsFalse_OnceTheJobIsAssigned()
    {
        var job = OpenJobWithApplicants(Guid.NewGuid(), Guid.NewGuid());
        job.Accept(job.Applications[0]);

        Assert.False(job.CanAccept(job.Applications[1]));
        Assert.Throws<InvalidOperationException>(() => job.Accept(job.Applications[1]));
    }

    [Fact]
    public void CanAccept_IsFalse_ForAnApplicationFromAnotherJob()
    {
        var job = OpenJobWithApplicants();
        var otherJob = OpenJobWithApplicants(Guid.NewGuid());

        Assert.False(job.CanAccept(otherJob.Applications[0]));
    }

    [Fact]
    public void Complete_OnlyWorksOnAnAssignedJob()
    {
        var job = OpenJobWithApplicants(Guid.NewGuid());
        Assert.False(job.CanComplete());

        job.Accept(job.Applications[0]);
        var now = DateTimeOffset.UtcNow;
        job.Complete(now);

        Assert.Equal(JobStatus.Completed, job.Status);
        Assert.Equal(now, job.CompletedAt);
    }

    [Fact]
    public void Cancel_RejectsPendingApplications()
    {
        var job = OpenJobWithApplicants(Guid.NewGuid());

        job.Cancel();

        Assert.Equal(JobStatus.Cancelled, job.Status);
        Assert.Equal(ApplicationStatus.Rejected, job.Applications[0].Status);
    }

    [Theory]
    [InlineData(JobStatus.Assigned)]
    [InlineData(JobStatus.Completed)]
    [InlineData(JobStatus.Cancelled)]
    public void OnlyAnOpenJob_CanBeCancelledOrAppliedFor(JobStatus status)
    {
        var job = new Job { Status = status };

        Assert.False(job.CanCancel());
        Assert.False(job.CanApply());
    }

    [Fact]
    public void Withdraw_OnlyWorksWhilePending()
    {
        var application = new JobApplication();

        application.Withdraw();

        Assert.Equal(ApplicationStatus.Withdrawn, application.Status);
        Assert.False(application.CanWithdraw()); // withdrawing is final
    }

    [Fact]
    public void HasApplicationFrom_CatchesDuplicates_EvenAfterWithdrawing()
    {
        var freelancerId = Guid.NewGuid();
        var job = OpenJobWithApplicants(freelancerId);
        job.Applications[0].Withdraw();

        Assert.True(job.HasApplicationFrom(freelancerId));
        Assert.False(job.HasApplicationFrom(Guid.NewGuid()));
    }
}
