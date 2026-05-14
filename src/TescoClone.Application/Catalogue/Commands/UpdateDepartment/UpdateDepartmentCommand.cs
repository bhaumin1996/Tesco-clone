using MediatR;

namespace TescoClone.Application.Catalogue.Commands.UpdateDepartment;

public sealed record UpdateDepartmentCommand(
    int DepartmentId,
    string Name,
    int AdminUserId) : IRequest;
