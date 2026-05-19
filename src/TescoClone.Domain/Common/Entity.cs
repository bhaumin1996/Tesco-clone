namespace TescoClone.Domain.Common;

// Base class providing an integer primary key for all domain entities.
public abstract class Entity
{
    public int Id { get; protected init; }
}
