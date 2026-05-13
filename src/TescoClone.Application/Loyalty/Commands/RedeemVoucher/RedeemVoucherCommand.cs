using MediatR;
using TescoClone.Application.Loyalty.DTOs;

namespace TescoClone.Application.Loyalty.Commands.RedeemVoucher;

public sealed record RedeemVoucherCommand(string Code, int OrderId) : IRequest<VoucherDto>;
