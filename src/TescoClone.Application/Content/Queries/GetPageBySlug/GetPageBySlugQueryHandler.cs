using MediatR;
using TescoClone.Application.Content.DTOs;
using TescoClone.Application.Content.Interfaces;

namespace TescoClone.Application.Content.Queries.GetPageBySlug;

public sealed class GetPageBySlugQueryHandler : IRequestHandler<GetPageBySlugQuery, PageDto?>
{
    private readonly IContentRepository _contentRepository;

    public GetPageBySlugQueryHandler(IContentRepository contentRepository)
    {
        _contentRepository = contentRepository;
    }

    public async Task<PageDto?> Handle(GetPageBySlugQuery request, CancellationToken cancellationToken)
    {
        return await _contentRepository.GetPageBySlugAsync(request.Slug, cancellationToken);
    }
}
