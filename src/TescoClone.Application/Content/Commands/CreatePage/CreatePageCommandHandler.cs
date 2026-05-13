using MediatR;
using TescoClone.Application.Content.DTOs;
using TescoClone.Application.Content.Interfaces;

namespace TescoClone.Application.Content.Commands.CreatePage;

public sealed class CreatePageCommandHandler : IRequestHandler<CreatePageCommand, int>
{
    private readonly IContentRepository _contentRepository;

    public CreatePageCommandHandler(IContentRepository contentRepository)
    {
        _contentRepository = contentRepository;
    }

    public Task<int> Handle(CreatePageCommand request, CancellationToken cancellationToken)
    {
        var dto = new PageDto(0, request.Title, request.Slug, request.Content, request.IsPublished, DateTime.UtcNow, null);
        return _contentRepository.CreatePageAsync(dto, request.AdminUserId, cancellationToken);
    }
}
