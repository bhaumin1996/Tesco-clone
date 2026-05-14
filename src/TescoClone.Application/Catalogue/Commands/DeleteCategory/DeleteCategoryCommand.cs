using MediatR;

namespace TescoClone.Application.Catalogue.Commands.DeleteCategory;

public sealed record DeleteCategoryCommand(
    int CategoryId,
    int AdminUserId) : IRequest;
