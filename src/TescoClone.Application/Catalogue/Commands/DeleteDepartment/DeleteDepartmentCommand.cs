using MediatR;

namespace TescoClone.Application.Catalogue.Commands.DeleteDepartment;

public sealed record DeleteDepartmentCommand(
    int DepartmentId,
    int AdminUserId) : IRequest;
