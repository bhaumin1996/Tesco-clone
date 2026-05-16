using MediatR;
using TescoClone.Application.Addresses.Interfaces;

namespace TescoClone.Application.Addresses.Commands.UpdateAddress;

public sealed class UpdateAddressCommandHandler : IRequestHandler<UpdateAddressCommand>
{
    private readonly IAddressRepository _addressRepository;

    public UpdateAddressCommandHandler(IAddressRepository addressRepository)
    {
        _addressRepository = addressRepository;
    }

    public async Task Handle(UpdateAddressCommand request, CancellationToken cancellationToken)
    {
        await _addressRepository.UpdateAsync(
            request.Id,
            request.UserId,
            request.AddressLine1,
            request.AddressLine2,
            request.TownCity,
            request.Postcode,
            request.IsDefault,
            cancellationToken);
    }
}
