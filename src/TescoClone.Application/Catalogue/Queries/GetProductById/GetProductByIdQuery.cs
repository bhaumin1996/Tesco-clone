using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetProductById;

public sealed record GetProductByIdQuery(int Id) : IRequest<ProductDto>;
