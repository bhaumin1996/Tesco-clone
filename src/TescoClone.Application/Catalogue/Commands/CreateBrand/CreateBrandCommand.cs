using MediatR;

namespace TescoClone.Application.Catalogue.Commands.CreateBrand;

public sealed record CreateBrandCommand(
    string Name,
    string Slug,
    string? LogoUrl,
    int AdminUserId) : IRequest<int>;
