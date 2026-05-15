using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Catalogue.Interfaces;

public interface IProductRepository
{
    Task<ProductDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<PaginatedResult<ProductDto>> SearchAsync(
        string? searchTerm,
        int? categoryId,
        int? brandId,
        decimal? minPrice,
        decimal? maxPrice,
        bool? inStockOnly,
        bool? clubcardOnly,
        IEnumerable<string>? brands,
        IEnumerable<string>? dietary,
        string? sortBy,
        string? sortDirection,
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ProductVariantDto>> GetVariantsAsync(int productId, CancellationToken cancellationToken = default);
}
