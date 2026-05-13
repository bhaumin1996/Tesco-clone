using FluentValidation;

namespace TescoClone.Application.Catalogue.Commands.AdjustInventory;

public sealed class AdjustInventoryCommandValidator : AbstractValidator<AdjustInventoryCommand>
{
    public AdjustInventoryCommandValidator()
    {
        RuleFor(x => x.ProductVariantId).GreaterThan(0).WithMessage("ProductVariantId must be a positive integer.");
        RuleFor(x => x.QuantityDelta).NotEqual(0).WithMessage("QuantityDelta must not be zero.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
