namespace TescoClone.Domain.Common;

// Thrown when an authenticated user lacks permission for the requested action; maps to HTTP 403.
public sealed class ForbiddenException : DomainException
{
    public ForbiddenException(string message) : base(message) { }
}
