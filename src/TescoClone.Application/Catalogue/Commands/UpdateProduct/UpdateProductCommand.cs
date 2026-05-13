using MediatR;

namespace TescoClone.Application.Catalogue.Commands.UpdateProduct;

public sealed record UpdateProductCommand(
    int ProductId,
    int CategoryId,
    int? BrandId,
    string Name,
    string? Description,
    decimal BasePrice,
    decimal? ClubcardPrice,
    string? ImageUrl,
    bool IsAvailable,
    int AdminUserId) : IRequest;
