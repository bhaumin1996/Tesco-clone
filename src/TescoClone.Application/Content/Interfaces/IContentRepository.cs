using TescoClone.Application.Common.Models;
using TescoClone.Application.Content.DTOs;

namespace TescoClone.Application.Content.Interfaces;

public interface IContentRepository
{
    Task<PaginatedResult<PageDto>> GetPagesAsync(bool? isPublished, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<PageDto?> GetPageByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<PageDto?> GetPageBySlugAsync(string slug, CancellationToken cancellationToken = default);
    Task<int> CreatePageAsync(PageDto page, int adminId, CancellationToken cancellationToken = default);
    Task UpdatePageAsync(PageDto page, int adminId, CancellationToken cancellationToken = default);
    Task SoftDeletePageAsync(int id, int adminId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<BannerDto>> GetBannersAsync(bool? isActive, CancellationToken cancellationToken = default);
    Task<int> CreateBannerAsync(BannerDto banner, int adminId, CancellationToken cancellationToken = default);
    Task UpdateBannerAsync(BannerDto banner, int adminId, CancellationToken cancellationToken = default);
    Task SoftDeleteBannerAsync(int id, int adminId, CancellationToken cancellationToken = default);
}
