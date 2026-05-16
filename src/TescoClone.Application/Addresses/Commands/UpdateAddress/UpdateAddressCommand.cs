using MediatR;

namespace TescoClone.Application.Addresses.Commands.UpdateAddress;

public sealed record UpdateAddressCommand(
    int Id,
    int UserId,
    string AddressLine1,
    string? AddressLine2,
    string TownCity,
    string Postcode,
    bool IsDefault) : IRequest;
