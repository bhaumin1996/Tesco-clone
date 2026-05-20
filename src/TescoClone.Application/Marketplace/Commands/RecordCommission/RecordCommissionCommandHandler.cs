using MediatR;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.RecordCommission;

public sealed class RecordCommissionCommandHandler : IRequestHandler<RecordCommissionCommand, RecordCommissionResultDto>
{
    private readonly IMarketplaceRepository _repository;

    public RecordCommissionCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<RecordCommissionResultDto> Handle(RecordCommissionCommand request, CancellationToken cancellationToken)
        => _repository.RecordCommissionAsync(
            request.SellerId,
            request.OrderLineId,
            request.SaleAmount,
            request.CategoryId,
            request.CreatedBy,
            cancellationToken);
}
