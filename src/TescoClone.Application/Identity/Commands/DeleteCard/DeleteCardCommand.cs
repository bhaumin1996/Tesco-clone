using MediatR;

namespace TescoClone.Application.Identity.Commands.DeleteCard;

public sealed record DeleteCardCommand(int CardId) : IRequest;
