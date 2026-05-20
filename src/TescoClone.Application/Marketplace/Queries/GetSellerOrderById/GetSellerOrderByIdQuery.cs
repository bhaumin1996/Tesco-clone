using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetSellerOrderById;

public sealed record GetSellerOrderByIdQuery(int SellerOrderId, int SellerId) : IRequest<SellerOrderDto?>;
