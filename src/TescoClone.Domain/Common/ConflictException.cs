namespace TescoClone.Domain.Common;

// Thrown when a state transition or uniqueness rule is violated; maps to HTTP 409.
public sealed class ConflictException : DomainException
{
    public ConflictException(string message) : base(message) { }
}
