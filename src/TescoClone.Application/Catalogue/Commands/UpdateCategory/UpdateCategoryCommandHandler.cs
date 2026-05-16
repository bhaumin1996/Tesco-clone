using System.Text.RegularExpressions;
using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.UpdateCategory;

public sealed class UpdateCategoryCommandHandler : IRequestHandler<UpdateCategoryCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public UpdateCategoryCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public async Task Handle(UpdateCategoryCommand request, CancellationToken cancellationToken)
    {
        var slug = GenerateSlug(request.Name);
        await _adminCatalogueRepository.UpdateCategoryAsync(
            request.CategoryId,
            request.Name,
            slug,
            request.DepartmentId,
            request.ImageUrl,
            request.AdminUserId,
            cancellationToken);
    }

    private static string GenerateSlug(string name)
    {
        var lower = name.ToLowerInvariant();
        var slug = Regex.Replace(lower, @"[^a-z0-9]+", "-");
        return slug.Trim('-');
    }
}
