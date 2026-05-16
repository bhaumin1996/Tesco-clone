using MediatR;
using TescoClone.Application.Addresses.DTOs;
using TescoClone.Application.Addresses.Interfaces;

namespace TescoClone.Application.Addresses.Queries.GetAddresses;

public sealed class GetAddressesQueryHandler : IRequestHandler<GetAddressesQuery, IReadOnlyList<AddressDto>>
{
    private readonly IAddressRepository _addressRepository;

    public GetAddressesQueryHandler(IAddressRepository addressRepository)
    {
        _addressRepository = addressRepository;
    }

    public async Task<IReadOnlyList<AddressDto>> Handle(GetAddressesQuery request, CancellationToken cancellationToken)
    {
        return await _addressRepository.GetByUserIdAsync(request.UserId, cancellationToken);
    }
}
