using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Dtos;

public record CreateReportRequest
(
    Guid ReporterId, 
    Guid JobId, 
    ReportReason Reason, 
    string Details
);

// UserId is the admin making the change
public record UpdateReportRequest
(
    Guid UserId, 
    ReportStatus Status
);

public record ReportDto
(
    Guid Id,
    Guid ReporterId,
    string ReporterName,
    Guid JobId,
    string JobTitle,
    ReportReason Reason,
    string Details,
    ReportStatus Status,
    DateTimeOffset CreatedAt
);

public static class ReportMapping
{
    public static ReportDto ToDto(this Report report) =>
        new(
            report.Id,
            report.ReporterId,
            $"{report.Reporter.FirstName} {report.Reporter.LastName}",
            report.JobId,
            report.Job.Title,
            report.Reason,
            report.Details,
            report.Status,
            report.CreatedAt
        );
}