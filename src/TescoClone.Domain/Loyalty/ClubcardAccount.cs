using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Loyalty;

// Loyalty module — Clubcard account tracking the points balance; RedeemPoints guards against overdraft.
public sealed class ClubcardAccount : Entity
{
    public int UserId { get; private set; }
    public string ClubcardNumber { get; private set; } = string.Empty;
    public int PointsBalance { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }
    public DateTime? ModifiedOn { get; private set; }

    private ClubcardAccount() { }

    public void AddPoints(int points)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(points);
        PointsBalance += points;
        ModifiedOn = DateTime.UtcNow;
    }

    public void RedeemPoints(int points)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(points);
        if (points > PointsBalance)
            throw new ConflictException("Insufficient Clubcard points balance.");
        PointsBalance -= points;
        ModifiedOn = DateTime.UtcNow;
    }
}
