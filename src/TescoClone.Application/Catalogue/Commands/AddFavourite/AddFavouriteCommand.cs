using MediatR;

namespace TescoClone.Application.Catalogue.Commands.AddFavourite;

public sealed record AddFavouriteCommand(int ProductId, int UserId) : IRequest<int>;
