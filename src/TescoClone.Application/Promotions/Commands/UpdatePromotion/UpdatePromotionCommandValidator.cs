using FluentValidation;

namespace TescoClone.Application.Promotions.Commands.UpdatePromotion;

public sealed class UpdatePromotionCommandValidator : AbstractValidator<UpdatePromotionCommand>
{
    public UpdatePromotionCommandValidator()
    {
        RuleFor(x => x.PromotionId).GreaterThan(0).WithMessage("PromotionId must be a positive integer.");
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200).WithMessage("Name is required and must not exceed 200 characters.");
        RuleFor(x => x.DiscountValue).GreaterThan(0).When(x => x.DiscountValue.HasValue).WithMessage("DiscountValue must be greater than 0.");
        RuleFor(x => x.DiscountPercent).InclusiveBetween(0.01m, 100m).When(x => x.DiscountPercent.HasValue).WithMessage("DiscountPercent must be between 0.01 and 100.");
        RuleFor(x => x.EndsAt).GreaterThan(x => x.StartsAt).When(x => x.StartsAt.HasValue && x.EndsAt.HasValue).WithMessage("EndsAt must be after StartsAt.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
