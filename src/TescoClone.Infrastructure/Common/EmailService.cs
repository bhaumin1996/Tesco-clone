using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Abstractions;

namespace TescoClone.Infrastructure.Common;

public sealed class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;

    public EmailService(ILogger<EmailService> logger)
    {
        _logger = logger;
    }

    public Task SendEmailAsync(string to, string subject, string body, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Sending email to {To} with subject {Subject}. Body: {Body}", to, subject, body);
        return Task.CompletedTask;
    }

    public Task SendPasswordResetEmailAsync(string to, string resetLink, CancellationToken cancellationToken = default)
    {
        var subject = "Reset your Tesco account password";
        var body = $@"
            <h1>Password Reset Request</h1>
            <p>You recently requested to reset your password for your Tesco account. Click the link below to reset it:</p>
            <p><a href='{resetLink}'>{resetLink}</a></p>
            <p>If you did not request a password reset, please ignore this email or contact support if you have questions.</p>
            <p>Thanks,<br>The Tesco Team</p>";
            
        return SendEmailAsync(to, subject, body, cancellationToken);
    }
}
