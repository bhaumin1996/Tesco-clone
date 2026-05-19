using MediatR;

namespace TescoClone.Application.Catalogue.Commands.RemoveFavourite;

public sealed record RemoveFavouriteCommand(int ProductId, int UserId) : IRequest;
