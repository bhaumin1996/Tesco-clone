using MediatR;

namespace TescoClone.Application.Catalogue.Commands.CreateCategory;

public sealed record CreateCategoryCommand(
    string Name,
    int DepartmentId,
    string? ImageUrl,
    int AdminUserId) : IRequest<int>;
