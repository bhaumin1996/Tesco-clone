using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Interfaces;

public interface IBrandRepository
{
    Task<IReadOnlyList<BrandDto>> GetAllAsync(CancellationToken cancellationToken = default);
}
