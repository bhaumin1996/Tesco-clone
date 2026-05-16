using MediatR;

namespace TescoClone.Application.Addresses.Commands.AddAddress;

public sealed record AddAddressCommand(
    int UserId,
    string AddressLine1,
    string? AddressLine2,
    string TownCity,
    string Postcode,
    bool IsDefault) : IRequest;
