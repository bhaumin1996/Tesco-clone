using MediatR;

namespace TescoClone.Application.Catalogue.Commands.UpdateCategory;

public sealed record UpdateCategoryCommand(
    int CategoryId,
    string Name,
    int DepartmentId,
    int AdminUserId) : IRequest;
