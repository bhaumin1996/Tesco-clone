namespace TescoClone.Domain.Common;

public sealed class ConflictException : DomainException
{
    public ConflictException(string message) : base(message) { }
}
