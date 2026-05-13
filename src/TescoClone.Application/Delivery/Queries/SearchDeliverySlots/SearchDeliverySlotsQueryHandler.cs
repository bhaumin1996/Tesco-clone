using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Delivery.DTOs;
using TescoClone.Application.Delivery.Interfaces;

namespace TescoClone.Application.Delivery.Queries.SearchDeliverySlots;

public sealed class SearchDeliverySlotsQueryHandler : IRequestHandler<SearchDeliverySlotsQuery, IReadOnlyList<DeliverySlotDto>>
{
    private readonly IDeliveryRepository _deliveryRepository;
    private readonly IClock _clock;

    public SearchDeliverySlotsQueryHandler(IDeliveryRepository deliveryRepository, IClock clock)
    {
        _deliveryRepository = deliveryRepository;
        _clock = clock;
    }

    public Task<IReadOnlyList<DeliverySlotDto>> Handle(SearchDeliverySlotsQuery request, CancellationToken cancellationToken)
    {
        var from = request.FromDate ?? _clock.UtcNow;
        var to = request.ToDate ?? _clock.UtcNow.AddDays(7);
        return _deliveryRepository.GetAvailableSlotsAsync(request.Postcode, request.DeliveryType, from, to, cancellationToken);
    }
}
