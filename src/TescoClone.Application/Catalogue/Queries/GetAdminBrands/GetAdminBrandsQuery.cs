using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetAdminBrands;

public sealed record GetAdminBrandsQuery : IRequest<IReadOnlyList<AdminBrandDto>>;
