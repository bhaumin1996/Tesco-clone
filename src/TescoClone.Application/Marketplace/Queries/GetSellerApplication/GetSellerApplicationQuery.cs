using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetSellerApplication;

public sealed record GetSellerApplicationQuery(int UserId) : IRequest<SellerApplicationDto?>;
