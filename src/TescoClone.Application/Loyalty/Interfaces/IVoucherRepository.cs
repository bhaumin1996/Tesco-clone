using TescoClone.Application.Loyalty.DTOs;

namespace TescoClone.Application.Loyalty.Interfaces;

public interface IVoucherRepository
{
    Task<IReadOnlyList<VoucherDto>> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<VoucherDto?> GetByCodeAsync(int userId, string code, CancellationToken cancellationToken = default);
    Task RedeemAsync(int userId, string code, int orderId, int modifiedBy, CancellationToken cancellationToken = default);
}
