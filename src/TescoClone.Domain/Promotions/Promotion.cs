using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Promotions;

public sealed class Promotion : Entity
{
    public string Name { get; private set; } = string.Empty;
    public PromotionType Type { get; private set; }
    public decimal DiscountValue { get; private set; }
    public int? MinimumQuantity { get; private set; }
    public decimal? MinimumSpend { get; private set; }
    public bool RequiresClubcard { get; private set; }
    public DateTime ValidFrom { get; private set; }
    public DateTime? ValidTo { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }
    public DateTime? ModifiedOn { get; private set; }

    private Promotion() { }

    public bool IsActive(DateTime utcNow) =>
        RecordStatus == RecordStatus.Active &&
        utcNow >= ValidFrom &&
        (ValidTo == null || utcNow <= ValidTo);
}
