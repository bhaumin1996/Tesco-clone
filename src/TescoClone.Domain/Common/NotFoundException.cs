namespace TescoClone.Domain.Common;

// Thrown when a requested resource does not exist; maps to HTTP 404.
public sealed class NotFoundException : DomainException
{
    public NotFoundException(string entityName, object key)
        : base($"{entityName} with key '{key}' was not found.") { }
}
