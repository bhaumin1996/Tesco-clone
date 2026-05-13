using MediatR;
using TescoClone.Application.Delivery.DTOs;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Delivery.Queries.SearchDeliverySlots;

public sealed record SearchDeliverySlotsQuery(
    string Postcode,
    DeliveryType? DeliveryType = null,
    DateTime? FromDate = null,
    DateTime? ToDate = null) : IRequest<IReadOnlyList<DeliverySlotDto>>;
