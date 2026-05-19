using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Identity;

// Identity module — customer/admin account aggregate with lockout and password-reset logic.
public sealed class User : Entity
{
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public string? PhoneNumber { get; private set; }
    public string? StripeCustomerId { get; private set; }
    public UserStatus Status { get; private set; }
    public int FailedLoginAttempts { get; private set; }
    public DateTime? LockedUntil { get; private set; }
    public string? PasswordResetToken { get; private set; }
    public DateTime? PasswordResetTokenExpires { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }
    public DateTime? ModifiedOn { get; private set; }

    private User() { }

    public static User Create(string firstName, string lastName, string email, string passwordHash, string? phoneNumber)
    {
        return new User
        {
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            PasswordHash = passwordHash,
            PhoneNumber = phoneNumber,
            Status = UserStatus.Active,
            FailedLoginAttempts = 0,
            RecordStatus = RecordStatus.Active,
            CreatedOn = DateTime.UtcNow
        };
    }

    public void SetStripeCustomerId(string stripeCustomerId)
    {
        StripeCustomerId = stripeCustomerId;
        ModifiedOn = DateTime.UtcNow;
    }

    public void RecordFailedLogin(int maxAttempts, TimeSpan lockoutDuration)
    {
        FailedLoginAttempts++;
        if (FailedLoginAttempts >= maxAttempts)
        {
            Status = UserStatus.Locked;
            LockedUntil = DateTime.UtcNow.Add(lockoutDuration);
        }
        ModifiedOn = DateTime.UtcNow;
    }

    public void ResetFailedLogins()
    {
        FailedLoginAttempts = 0;
        Status = UserStatus.Active;
        LockedUntil = null;
        ModifiedOn = DateTime.UtcNow;
    }

    public void SetPasswordResetToken(string? token, DateTime? expires)
    {
        PasswordResetToken = token;
        PasswordResetTokenExpires = expires;
        ModifiedOn = DateTime.UtcNow;
    }

    public bool IsLocked(DateTime utcNow) =>
        Status == UserStatus.Locked && (LockedUntil == null || LockedUntil > utcNow);

    public static User Hydrate(
        int id,
        string firstName,
        string lastName,
        string email,
        string passwordHash,
        string? phoneNumber,
        string? stripeCustomerId,
        UserStatus status,
        int failedLoginAttempts,
        DateTime? lockedUntil,
        string? passwordResetToken,
        DateTime? passwordResetTokenExpires,
        RecordStatus recordStatus,
        DateTime createdOn,
        DateTime? modifiedOn)
    {
        return new User
        {
            Id = id,
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            PasswordHash = passwordHash,
            PhoneNumber = phoneNumber,
            StripeCustomerId = stripeCustomerId,
            Status = status,
            FailedLoginAttempts = failedLoginAttempts,
            LockedUntil = lockedUntil,
            PasswordResetToken = passwordResetToken,
            PasswordResetTokenExpires = passwordResetTokenExpires,
            RecordStatus = recordStatus,
            CreatedOn = createdOn,
            ModifiedOn = modifiedOn
        };
    }
}
