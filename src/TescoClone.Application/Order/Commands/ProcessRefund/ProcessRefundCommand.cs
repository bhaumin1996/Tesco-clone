using MediatR;

namespace TescoClone.Application.Order.Commands.ProcessRefund;

public sealed record ProcessRefundCommand(
    int OrderId,
    decimal RefundAmount,
    string Reason,
    int AdminUserId) : IRequest;
