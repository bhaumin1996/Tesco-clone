using System.Text.Json.Serialization;
using MediatR;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Commands.PlaceOrder;

public sealed record PlaceOrderCommand(
    [property: JsonPropertyName("deliverySlotId")] int? DeliverySlotId,
    [property: JsonPropertyName("deliveryAddress")] string? DeliveryAddress,
    [property: JsonPropertyName("deliveryCharge")] decimal DeliveryCharge,
    [property: JsonPropertyName("paymentMethodId")] string PaymentMethodId,
    [property: JsonPropertyName("saveCard")] bool SaveCard = false) : IRequest<OrderDto>;
