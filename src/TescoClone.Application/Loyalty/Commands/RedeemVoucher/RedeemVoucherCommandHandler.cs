using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Loyalty.DTOs;
using TescoClone.Application.Loyalty.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Loyalty.Commands.RedeemVoucher;

public sealed class RedeemVoucherCommandHandler : IRequestHandler<RedeemVoucherCommand, VoucherDto>
{
    private readonly IVoucherRepository _voucherRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IClock _clock;

    public RedeemVoucherCommandHandler(IVoucherRepository voucherRepository, ICurrentUser currentUser, IClock clock)
    {
        _voucherRepository = voucherRepository;
        _currentUser = currentUser;
        _clock = clock;
    }

    public async Task<VoucherDto> Handle(RedeemVoucherCommand request, CancellationToken cancellationToken)
    {
        var voucher = await _voucherRepository.GetByCodeAsync(_currentUser.UserId, request.Code, cancellationToken)
            ?? throw new NotFoundException("Voucher", request.Code);

        if (voucher.IsRedeemed)
            throw new ConflictException("This voucher has already been redeemed.");

        var now = _clock.UtcNow;
        if (now < voucher.ValidFrom || now > voucher.ValidTo)
            throw new ConflictException("This voucher is not valid at this time.");

        await _voucherRepository.RedeemAsync(_currentUser.UserId, request.Code, request.OrderId, _currentUser.UserId, cancellationToken);

        return voucher with { IsRedeemed = true };
    }
}
