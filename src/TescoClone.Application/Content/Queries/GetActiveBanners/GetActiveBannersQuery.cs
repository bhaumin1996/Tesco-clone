using MediatR;
using TescoClone.Application.Content.DTOs;

namespace TescoClone.Application.Content.Queries.GetActiveBanners;

public sealed record GetActiveBannersQuery : IRequest<IReadOnlyList<BannerDto>>;
