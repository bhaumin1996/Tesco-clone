using System.Text.RegularExpressions;
using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.CreateCategory;

public sealed class CreateCategoryCommandHandler : IRequestHandler<CreateCategoryCommand, int>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public CreateCategoryCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<int> Handle(CreateCategoryCommand request, CancellationToken cancellationToken)
    {
        var slug = GenerateSlug(request.Name);
        return _adminCatalogueRepository.CreateCategoryAsync(request.Name, slug, request.DepartmentId, request.ImageUrl, request.AdminUserId, cancellationToken);
    }

    private static string GenerateSlug(string name)
    {
        var lower = name.ToLowerInvariant();
        var slug = Regex.Replace(lower, @"[^a-z0-9]+", "-");
        return slug.Trim('-');
    }
}
