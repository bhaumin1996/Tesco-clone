using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Catalogue;

// Catalogue module — top-level product grouping shown in the storefront navigation (e.g. Fresh Food).
public sealed class Department : Entity
{
    public string Name { get; private set; } = string.Empty;
    public string Slug { get; private set; } = string.Empty;
    public string? ImageUrl { get; private set; }
    public int DisplayOrder { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private Department() { }
}
