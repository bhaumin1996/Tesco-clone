using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetAdminInventory;

public sealed record GetAdminInventoryQuery : IRequest<IReadOnlyList<AdminInventoryDto>>;
