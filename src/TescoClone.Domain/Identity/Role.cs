using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Identity;

// Identity module — named permission role (User, Admin, SuperAdmin).
public sealed class Role : Entity
{
    public string Name { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private Role() { }
}
