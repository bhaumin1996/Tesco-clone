using MediatR;
using TescoClone.Application.Addresses.DTOs;

namespace TescoClone.Application.Addresses.Queries.GetAddresses;

public sealed record GetAddressesQuery(int UserId) : IRequest<IReadOnlyList<AddressDto>>;
