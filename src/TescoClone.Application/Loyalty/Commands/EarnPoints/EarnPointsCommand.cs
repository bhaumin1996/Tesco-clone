using MediatR;

namespace TescoClone.Application.Loyalty.Commands.EarnPoints;

public sealed record EarnPointsCommand(int UserId, int Points, string Description, int? OrderId = null) : IRequest;
