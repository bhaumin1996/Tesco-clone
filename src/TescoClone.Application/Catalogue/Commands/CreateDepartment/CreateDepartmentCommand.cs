using MediatR;

namespace TescoClone.Application.Catalogue.Commands.CreateDepartment;

public sealed record CreateDepartmentCommand(
    string Name,
    string Slug,
    string? ImageUrl,
    int AdminUserId) : IRequest<int>;
