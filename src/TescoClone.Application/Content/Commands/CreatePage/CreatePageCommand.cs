using MediatR;

namespace TescoClone.Application.Content.Commands.CreatePage;

public sealed record CreatePageCommand(
    string Title,
    string Slug,
    string? Content,
    bool IsPublished,
    int AdminUserId) : IRequest<int>;
