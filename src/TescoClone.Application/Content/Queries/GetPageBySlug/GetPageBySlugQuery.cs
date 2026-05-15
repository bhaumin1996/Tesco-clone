using MediatR;
using TescoClone.Application.Content.DTOs;

namespace TescoClone.Application.Content.Queries.GetPageBySlug;

public record GetPageBySlugQuery(string Slug) : IRequest<PageDto?>;
