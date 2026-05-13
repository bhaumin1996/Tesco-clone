using MediatR;
using TescoClone.Application.Loyalty.DTOs;
using TescoClone.Application.Loyalty.Interfaces;

namespace TescoClone.Application.Loyalty.Queries.GetVouchers;

public sealed class GetVouchersQueryHandler : IRequestHandler<GetVouchersQuery, IReadOnlyList<VoucherDto>>
{
    private readonly IVoucherRepository _voucherRepository;

    public GetVouchersQueryHandler(IVoucherRepository voucherRepository)
    {
        _voucherRepository = voucherRepository;
    }

    public Task<IReadOnlyList<VoucherDto>> Handle(GetVouchersQuery request, CancellationToken cancellationToken) =>
        _voucherRepository.GetByUserIdAsync(request.UserId, cancellationToken);
}
