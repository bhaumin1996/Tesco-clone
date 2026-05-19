using TescoClone.Domain.Common;

namespace TescoClone.Domain.Identity;

// Identity module — Stripe-tokenised saved payment card; no raw card data is ever stored.
public sealed class UserCard : Entity
{
    public int UserId { get; private set; }
    public string PaymentMethodId { get; private set; } = string.Empty;
    public string Brand { get; private set; } = string.Empty;
    public string Last4 { get; private set; } = string.Empty;
    public int ExpiryMonth { get; private set; }
    public int ExpiryYear { get; private set; }
    public bool IsDefault { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private UserCard() { }

    public static UserCard Create(
        int userId, 
        string paymentMethodId, 
        string brand, 
        string last4, 
        int expiryMonth, 
        int expiryYear, 
        bool isDefault)
    {
        return new UserCard
        {
            UserId = userId,
            PaymentMethodId = paymentMethodId,
            Brand = brand,
            Last4 = last4,
            ExpiryMonth = expiryMonth,
            ExpiryYear = expiryYear,
            IsDefault = isDefault,
            CreatedOn = DateTime.UtcNow
        };
    }

    public static UserCard Hydrate(
        int id,
        int userId,
        string paymentMethodId,
        string brand,
        string last4,
        int expiryMonth,
        int expiryYear,
        bool isDefault,
        DateTime createdOn)
    {
        return new UserCard
        {
            Id = id,
            UserId = userId,
            PaymentMethodId = paymentMethodId,
            Brand = brand,
            Last4 = last4,
            ExpiryMonth = expiryMonth,
            ExpiryYear = expiryYear,
            IsDefault = isDefault,
            CreatedOn = createdOn
        };
    }
}
