using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Identity;

public sealed class User : Entity
{
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public string? PhoneNumber { get; private set; }
    public UserStatus Status { get; private set; }
    public int FailedLoginAttempts { get; private set; }
    public DateTime? LockedUntil { get; private set; }
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

    public bool IsLocked(DateTime utcNow) =>
        Status == UserStatus.Locked && (LockedUntil == null || LockedUntil > utcNow);

    public static User Hydrate(
        int id,
        string firstName,
        string lastName,
        string email,
        string passwordHash,
        string? phoneNumber,
        UserStatus status,
        int failedLoginAttempts,
        DateTime? lockedUntil,
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
            Status = status,
            FailedLoginAttempts = failedLoginAttempts,
            LockedUntil = lockedUntil,
            RecordStatus = recordStatus,
            CreatedOn = createdOn,
            ModifiedOn = modifiedOn
        };
    }
}
