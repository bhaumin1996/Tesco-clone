using FluentValidation;

namespace TescoClone.Application.Catalogue.Commands.CreateProductVariant;

public sealed class CreateProductVariantCommandValidator : AbstractValidator<CreateProductVariantCommand>
{
    public CreateProductVariantCommandValidator()
    {
        RuleFor(x => x.ProductId).GreaterThan(0);
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(100);
        RuleFor(x => x.VariantName).MaximumLength(200).When(x => x.VariantName is not null);
        RuleFor(x => x.Barcode).MaximumLength(50).When(x => x.Barcode is not null);
        RuleFor(x => x.InitialQuantity).GreaterThanOrEqualTo(0);
        RuleFor(x => x.LowStockThreshold).GreaterThanOrEqualTo(0);
        RuleFor(x => x.AdminUserId).GreaterThan(0);
    }
}
