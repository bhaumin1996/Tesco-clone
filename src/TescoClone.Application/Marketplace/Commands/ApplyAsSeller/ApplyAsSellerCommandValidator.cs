using FluentValidation;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.ApplyAsSeller;

public sealed class ApplyAsSellerCommandValidator : AbstractValidator<ApplyAsSellerCommand>
{
    public ApplyAsSellerCommandValidator(IMarketplaceRepository repository)
    {
        RuleFor(x => x.UserId).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Dto.ContactName).NotEmpty().WithMessage("Contact name is required.").When(x => x.UserId == 0);
        RuleFor(x => x.Dto.BusinessName).NotEmpty().MaximumLength(300);
        RuleFor(x => x.Dto.BusinessEmail).NotEmpty().EmailAddress().MaximumLength(256);
        RuleFor(x => x.Dto.Phone)
            .NotEmpty().WithMessage("Phone number is required.")
            .MinimumLength(10).WithMessage("Phone number must be at least 10 digits.")
            .MaximumLength(15).WithMessage("Phone number must not exceed 15 digits.");
        RuleFor(x => x.Dto.RegistrationNumber).MaximumLength(50).When(x => x.Dto.RegistrationNumber != null);
        RuleFor(x => x.Dto.VatNumber)
            .MinimumLength(9).WithMessage("VAT number must be at least 9 characters.")
            .MaximumLength(15).WithMessage("VAT number must not exceed 15 characters.")
            .When(x => !string.IsNullOrEmpty(x.Dto.VatNumber));

        RuleFor(x => x.Dto)
            .CustomAsync(async (dto, context, cancellationToken) =>
            {
                var conflict = await repository.CheckSellerUniqueAsync(
                    dto.BusinessName,
                    dto.BusinessEmail,
                    dto.Phone ?? string.Empty,
                    dto.Website,
                    cancellationToken);

                if (conflict != null)
                {
                    if (conflict == "BusinessName")
                    {
                        context.AddFailure("Dto.BusinessName", "Business name already exists.");
                    }
                    else if (conflict == "Email")
                    {
                        context.AddFailure("Dto.BusinessEmail", "Email address already exists.");
                    }
                    else if (conflict == "Phone")
                    {
                        context.AddFailure("Dto.Phone", "Phone number already exists.");
                    }
                    else if (conflict == "Website")
                    {
                        context.AddFailure("Dto.Website", "Website already exists.");
                    }
                }
            });
    }
}
