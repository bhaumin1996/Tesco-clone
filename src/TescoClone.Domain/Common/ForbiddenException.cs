namespace TescoClone.Domain.Common;

public sealed class ForbiddenException : DomainException
{
    public ForbiddenException(string message) : base(message) { }
}
