using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Interfaces;

public interface ICategoryRepository
{
    Task<IReadOnlyList<CategoryDto>> GetAllAsync(int? departmentId = null, CancellationToken cancellationToken = default);
    Task<CategoryDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
}
