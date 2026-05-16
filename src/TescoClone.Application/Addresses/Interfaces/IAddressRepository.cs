using TescoClone.Application.Addresses.DTOs;

namespace TescoClone.Application.Addresses.Interfaces;

public interface IAddressRepository
{
    Task<IReadOnlyList<AddressDto>> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task AddAsync(int userId, string line1, string? line2, string town, string postcode, bool isDefault, CancellationToken cancellationToken = default);
    Task UpdateAsync(int addressId, int userId, string line1, string? line2, string town, string postcode, bool isDefault, CancellationToken cancellationToken = default);
    Task DeleteAsync(int addressId, int userId, CancellationToken cancellationToken = default);
    Task SetDefaultAsync(int addressId, int userId, CancellationToken cancellationToken = default);
    Task ImportFromOrdersAsync(int userId, CancellationToken cancellationToken = default);
}
