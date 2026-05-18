using MediatR;

namespace TescoClone.Application.Catalogue.Commands.UpdateBrand;

public sealed record UpdateBrandCommand(
    int BrandId,
    string Name,
    string Slug,
    string? LogoUrl,
    int AdminUserId) : IRequest;
