using FluentValidation;

namespace TescoClone.Application.Catalogue.Queries.SearchProducts;

public sealed class SearchProductsQueryValidator : AbstractValidator<SearchProductsQuery>
{
    private static readonly string[] AllowedSortFields = ["name", "price", "relevance"];
    private static readonly string[] AllowedSortDirections = ["asc", "desc"];

    public SearchProductsQueryValidator()
    {
        RuleFor(x => x.PageNumber).GreaterThan(0);
        RuleFor(x => x.PageSize).InclusiveBetween(1, 100);
        RuleFor(x => x.MinPrice).GreaterThanOrEqualTo(0).When(x => x.MinPrice.HasValue);
        RuleFor(x => x.MaxPrice).GreaterThanOrEqualTo(0).When(x => x.MaxPrice.HasValue);
        RuleFor(x => x.SortBy)
            .Must(v => AllowedSortFields.Contains(v!.ToLowerInvariant()))
            .When(x => x.SortBy != null)
            .WithMessage($"SortBy must be one of: {string.Join(", ", AllowedSortFields)}");
        RuleFor(x => x.SortDirection)
            .Must(v => AllowedSortDirections.Contains(v!.ToLowerInvariant()))
            .When(x => x.SortDirection != null)
            .WithMessage("SortDirection must be 'asc' or 'desc'.");
    }
}
