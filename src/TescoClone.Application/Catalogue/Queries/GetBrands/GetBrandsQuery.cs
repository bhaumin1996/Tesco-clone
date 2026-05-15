using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetBrands;

public sealed record GetBrandsQuery : IRequest<IReadOnlyList<BrandDto>>;
