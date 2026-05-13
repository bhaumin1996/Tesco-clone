namespace TescoClone.Application.Common.Abstractions;

public interface ICurrentUser
{
    int UserId { get; }
    string Email { get; }
    IReadOnlyList<string> Roles { get; }
    bool IsAuthenticated { get; }
}
