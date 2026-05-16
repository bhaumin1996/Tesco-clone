using MediatR;
using TescoClone.Application.Addresses.Interfaces;

namespace TescoClone.Application.Addresses.Commands.AddAddress;

public sealed class AddAddressCommandHandler : IRequestHandler<AddAddressCommand>
{
    private readonly IAddressRepository _addressRepository;

    public AddAddressCommandHandler(IAddressRepository addressRepository)
    {
        _addressRepository = addressRepository;
    }

    public async Task Handle(AddAddressCommand request, CancellationToken cancellationToken)
    {
        await _addressRepository.AddAsync(
            request.UserId,
            request.AddressLine1,
            request.AddressLine2,
            request.TownCity,
            request.Postcode,
            request.IsDefault,
            cancellationToken);
    }
}
