using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetDepartments;

public sealed record GetDepartmentsQuery : IRequest<IReadOnlyList<DepartmentDto>>;
