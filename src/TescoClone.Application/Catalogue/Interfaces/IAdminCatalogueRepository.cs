using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Catalogue.Interfaces;

public interface IAdminCatalogueRepository
{
    Task<PaginatedResult<AdminProductDto>> GetProductsAsync(string? search, int? categoryId, int? departmentId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<int> CreateProductAsync(AdminProductDto product, int adminId, CancellationToken cancellationToken = default);
    Task UpdateProductAsync(AdminProductDto product, int adminId, CancellationToken cancellationToken = default);
    Task SoftDeleteProductAsync(int productId, int adminId, CancellationToken cancellationToken = default);
    Task<int> CreateCategoryAsync(string name, int departmentId, int adminId, CancellationToken cancellationToken = default);
    Task UpdateCategoryAsync(int categoryId, string name, int departmentId, int adminId, CancellationToken cancellationToken = default);
    Task SoftDeleteCategoryAsync(int categoryId, int adminId, CancellationToken cancellationToken = default);
    Task<int> CreateDepartmentAsync(string name, int adminId, CancellationToken cancellationToken = default);
    Task UpdateDepartmentAsync(int departmentId, string name, int adminId, CancellationToken cancellationToken = default);
    Task AdjustInventoryAsync(int productVariantId, int quantityDelta, int adminId, CancellationToken cancellationToken = default);
}
