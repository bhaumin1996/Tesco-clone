using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetAdminCategories;

public sealed record GetAdminCategoriesQuery : IRequest<IReadOnlyList<AdminCategoryDto>>;
