using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetCategories;

public sealed record GetCategoriesQuery(int? DepartmentId = null) : IRequest<IReadOnlyList<CategoryDto>>;
