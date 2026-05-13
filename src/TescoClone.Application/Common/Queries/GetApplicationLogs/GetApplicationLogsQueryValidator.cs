using FluentValidation;

namespace TescoClone.Application.Common.Queries.GetApplicationLogs;

public sealed class GetApplicationLogsQueryValidator : AbstractValidator<GetApplicationLogsQuery>
{
    private static readonly HashSet<string> ValidLevels = new(StringComparer.OrdinalIgnoreCase)
        { "Information", "Warning", "Error", "Critical" };

    public GetApplicationLogsQueryValidator()
    {
        RuleFor(x => x.PageNumber).GreaterThan(0).WithMessage("PageNumber must be greater than 0.");
        RuleFor(x => x.PageSize).InclusiveBetween(1, 100).WithMessage("PageSize must be between 1 and 100.");
        RuleFor(x => x.Level).Must(l => l == null || ValidLevels.Contains(l))
            .WithMessage("Level must be one of: Information, Warning, Error, Critical.");
        RuleFor(x => x.To).GreaterThan(x => x.From).When(x => x.From.HasValue && x.To.HasValue)
            .WithMessage("To date must be after From date.");
    }
}
