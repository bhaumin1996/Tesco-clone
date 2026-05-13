using FluentValidation;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.Commands.UpdateOrderStatus;

public sealed class UpdateOrderStatusCommandValidator : AbstractValidator<UpdateOrderStatusCommand>
{
    public UpdateOrderStatusCommandValidator()
    {
        RuleFor(x => x.OrderId).GreaterThan(0).WithMessage("OrderId must be a positive integer.");
        RuleFor(x => x.NewStatus).IsInEnum().WithMessage("NewStatus must be a valid OrderStatus value.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
