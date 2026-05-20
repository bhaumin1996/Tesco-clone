using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.ReviewApplication;

public sealed class ReviewApplicationCommandValidator : AbstractValidator<ReviewApplicationCommand>
{
    private static readonly string[] ValidDecisions = ["Approve", "Reject"];

    public ReviewApplicationCommandValidator()
    {
        RuleFor(x => x.ApplicationId).GreaterThan(0);
        RuleFor(x => x.Decision).NotEmpty().Must(d => ValidDecisions.Contains(d, StringComparer.OrdinalIgnoreCase))
            .WithMessage("Decision must be 'Approve' or 'Reject'.");
        RuleFor(x => x.ReviewNotes).MaximumLength(1000).When(x => x.ReviewNotes != null);
    }
}
