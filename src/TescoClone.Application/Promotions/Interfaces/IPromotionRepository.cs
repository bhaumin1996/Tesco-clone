using TescoClone.Application.Common.Models;
using TescoClone.Application.Promotions.DTOs;

namespace TescoClone.Application.Promotions.Interfaces;

public interface IPromotionRepository
{
    Task<PaginatedResult<PromotionDto>> GetPromotionsAsync(bool? isActive, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<PromotionDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<int> CreateAsync(PromotionDto promotion, int adminId, CancellationToken cancellationToken = default);
    Task UpdateAsync(PromotionDto promotion, int adminId, CancellationToken cancellationToken = default);
    Task SoftDeleteAsync(int id, int adminId, CancellationToken cancellationToken = default);
}
