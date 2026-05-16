using MediatR;

namespace TescoClone.Application.Addresses.Commands.DeleteAddress;

public sealed record DeleteAddressCommand(int Id, int UserId) : IRequest;
