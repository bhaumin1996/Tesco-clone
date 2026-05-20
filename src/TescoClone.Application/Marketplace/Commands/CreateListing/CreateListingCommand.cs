using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Commands.CreateListing;

public sealed record CreateListingCommand(
    int SellerId,
    CreateListingDto Dto,
    int CreatedBy) : IRequest<int>;
