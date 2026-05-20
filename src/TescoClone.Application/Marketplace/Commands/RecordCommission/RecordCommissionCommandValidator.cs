using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.RecordCommission;

public sealed class RecordCommissionCommandValidator : AbstractValidator<RecordCommissionCommand>
{
    public RecordCommissionCommandValidator()
    {
        RuleFor(x => x.SellerId).GreaterThan(0);
        RuleFor(x => x.OrderLineId).GreaterThan(0);
        RuleFor(x => x.SaleAmount).GreaterThan(0);
    }
}
