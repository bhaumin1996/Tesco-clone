using MediatR;

namespace TescoClone.Application.Catalogue.Commands.CreateProduct;

public sealed record CreateProductCommand(
    int CategoryId,
    int? BrandId,
    string Name,
    string Slug,
    string? Description,
    decimal BasePrice,
    decimal? ClubcardPrice,
    string? ImageUrl,
    bool IsAvailable,
    int AdminUserId) : IRequest<int>;
