using MediatR;

namespace TescoClone.Application.Order.Commands.CancelOrder;

public sealed record CancelOrderCommand(int OrderId) : IRequest;
