using MediatR;
using TescoClone.Application.Loyalty.DTOs;

namespace TescoClone.Application.Loyalty.Queries.GetVouchers;

public sealed record GetVouchersQuery(int UserId) : IRequest<IReadOnlyList<VoucherDto>>;
