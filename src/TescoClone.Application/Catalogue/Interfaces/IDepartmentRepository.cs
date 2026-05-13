using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Interfaces;

public interface IDepartmentRepository
{
    Task<IReadOnlyList<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DepartmentDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
}
