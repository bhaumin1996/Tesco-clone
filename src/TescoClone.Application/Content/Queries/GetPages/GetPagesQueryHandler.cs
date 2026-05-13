using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Content.DTOs;
using TescoClone.Application.Content.Interfaces;

namespace TescoClone.Application.Content.Queries.GetPages;

public sealed class GetPagesQueryHandler : IRequestHandler<GetPagesQuery, PaginatedResult<PageDto>>
{
    private readonly IContentRepository _contentRepository;

    public GetPagesQueryHandler(IContentRepository contentRepository)
    {
        _contentRepository = contentRepository;
    }

    public Task<PaginatedResult<PageDto>> Handle(GetPagesQuery request, CancellationToken cancellationToken) =>
        _contentRepository.GetPagesAsync(request.IsPublished, request.PageNumber, request.PageSize, cancellationToken);
}
