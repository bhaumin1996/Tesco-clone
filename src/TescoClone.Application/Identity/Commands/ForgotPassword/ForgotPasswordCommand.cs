using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;

namespace TescoClone.Application.Identity.Commands.ForgotPassword;

public sealed record ForgotPasswordCommand(string Email) : IRequest;

public sealed class ForgotPasswordCommandHandler : IRequestHandler<ForgotPasswordCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IEmailService _emailService;

    public ForgotPasswordCommandHandler(IUserRepository userRepository, IEmailService emailService)
    {
        _userRepository = userRepository;
        _emailService = emailService;
    }

    public async Task Handle(ForgotPasswordCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email, cancellationToken);
        if (user == null)
        {
            // We don't want to reveal if a user exists or not
            return;
        }

        var token = Guid.NewGuid().ToString("N");
        var expiresAt = DateTime.UtcNow.AddHours(2);

        await _userRepository.SetPasswordResetTokenAsync(user.Email, token, expiresAt, cancellationToken);

        // In a real app, this would be a URL to your frontend
        var resetLink = $"http://localhost:4200/auth/reset-password?token={token}";
        
        await _emailService.SendPasswordResetEmailAsync(user.Email, resetLink, cancellationToken);
    }
}
