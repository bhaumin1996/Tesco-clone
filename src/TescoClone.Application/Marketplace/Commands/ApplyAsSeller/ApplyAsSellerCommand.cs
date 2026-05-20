using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Commands.ApplyAsSeller;

public sealed record ApplyAsSellerCommand(int UserId, ApplyAsSellerDto Dto) : IRequest<int>;
