using MediatR;

namespace TescoClone.Application.Catalogue.Commands.AdjustInventory;

public sealed record AdjustInventoryCommand(
    int ProductVariantId,
    int QuantityDelta,
    int AdminUserId) : IRequest;
