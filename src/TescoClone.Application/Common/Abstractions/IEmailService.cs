namespace TescoClone.Application.Common.Abstractions;

public interface IEmailService
{
    Task SendEmailAsync(string to, string subject, string body, CancellationToken cancellationToken = default);
    Task SendPasswordResetEmailAsync(string to, string resetLink, CancellationToken cancellationToken = default);
}
