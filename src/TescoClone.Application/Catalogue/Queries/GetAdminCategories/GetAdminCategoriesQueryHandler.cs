using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetAdminCategories;

public sealed class GetAdminCategoriesQueryHandler : IRequestHandler<GetAdminCategoriesQuery, IReadOnlyList<AdminCategoryDto>>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public GetAdminCategoriesQueryHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<IReadOnlyList<AdminCategoryDto>> Handle(GetAdminCategoriesQuery request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.GetCategoriesAsync(cancellationToken);
}
