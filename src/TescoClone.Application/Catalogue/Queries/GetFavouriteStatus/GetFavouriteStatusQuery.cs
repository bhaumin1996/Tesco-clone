using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetFavouriteStatus;

public sealed record GetFavouriteStatusQuery(int ProductId, int UserId) : IRequest<FavouriteStatusDto>;
