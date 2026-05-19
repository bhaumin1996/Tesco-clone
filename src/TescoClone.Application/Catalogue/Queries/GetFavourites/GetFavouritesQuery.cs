using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetFavourites;

public sealed record GetFavouritesQuery(int UserId) : IRequest<IReadOnlyList<FavouriteDto>>;
