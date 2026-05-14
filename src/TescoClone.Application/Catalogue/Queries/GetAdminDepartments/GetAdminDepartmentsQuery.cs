using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetAdminDepartments;

public sealed record GetAdminDepartmentsQuery : IRequest<IReadOnlyList<AdminDepartmentDto>>;
