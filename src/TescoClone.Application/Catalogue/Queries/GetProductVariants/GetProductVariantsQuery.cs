using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetProductVariants;

public sealed record GetProductVariantsQuery(int ProductId) : IRequest<IReadOnlyList<ProductVariantDto>>;
