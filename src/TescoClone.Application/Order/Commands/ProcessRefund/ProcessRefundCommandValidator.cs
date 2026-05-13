using FluentValidation;

namespace TescoClone.Application.Order.Commands.ProcessRefund;

public sealed class ProcessRefundCommandValidator : AbstractValidator<ProcessRefundCommand>
{
    public ProcessRefundCommandValidator()
    {
        RuleFor(x => x.OrderId).GreaterThan(0).WithMessage("OrderId must be a positive integer.");
        RuleFor(x => x.RefundAmount).GreaterThan(0).WithMessage("RefundAmount must be greater than 0.");
        RuleFor(x => x.Reason).NotEmpty().MaximumLength(500).WithMessage("Reason is required and must not exceed 500 characters.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
