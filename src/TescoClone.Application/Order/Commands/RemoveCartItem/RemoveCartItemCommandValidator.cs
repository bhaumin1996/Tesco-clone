using FluentValidation;

namespace TescoClone.Application.Order.Commands.RemoveCartItem;

public sealed class RemoveCartItemCommandValidator : AbstractValidator<RemoveCartItemCommand>
{
    public RemoveCartItemCommandValidator()
    {
        RuleFor(x => x.ProductVariantId).GreaterThan(0);
    }
}
