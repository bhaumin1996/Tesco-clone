namespace TescoClone.Domain.Common;

// Base class for domain-layer business rule violations.
public abstract class DomainException : Exception
{
    protected DomainException(string message) : base(message) { }
}
