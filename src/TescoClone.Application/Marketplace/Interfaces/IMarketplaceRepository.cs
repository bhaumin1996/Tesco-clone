using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Interfaces;

public interface IMarketplaceRepository
{
    Task<PaginatedResult<SellerDto>> GetSellersAsync(string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<SellerDto?> GetSellerByIdAsync(int id, CancellationToken cancellationToken = default);
    Task ApproveSellerAsync(int sellerId, int adminId, CancellationToken cancellationToken = default);
    Task SuspendSellerAsync(int sellerId, string reason, int adminId, CancellationToken cancellationToken = default);
    Task<PaginatedResult<DisputeDto>> GetDisputesAsync(string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task ResolveDisputeAsync(int disputeId, string resolution, int adminId, CancellationToken cancellationToken = default);
}
