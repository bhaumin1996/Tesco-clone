using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Catalogue;

// Catalogue module — product category nested under a department; supports one level of sub-categories via ParentCategoryId.
public sealed class Category : Entity
{
    public int DepartmentId { get; private set; }
    public int? ParentCategoryId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string Slug { get; private set; } = string.Empty;
    public string? ImageUrl { get; private set; }
    public int DisplayOrder { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private Category() { }
}
