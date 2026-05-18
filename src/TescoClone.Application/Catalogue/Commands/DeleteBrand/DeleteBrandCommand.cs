using MediatR;

namespace TescoClone.Application.Catalogue.Commands.DeleteBrand;

public sealed record DeleteBrandCommand(
    int BrandId,
    int AdminUserId) : IRequest;
