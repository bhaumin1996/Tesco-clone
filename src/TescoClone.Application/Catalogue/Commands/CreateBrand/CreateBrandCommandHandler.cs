using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.CreateBrand;

public sealed class CreateBrandCommandHandler : IRequestHandler<CreateBrandCommand, int>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public CreateBrandCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<int> Handle(CreateBrandCommand request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.CreateBrandAsync(request.Name, request.Slug, request.LogoUrl, request.AdminUserId, cancellationToken);
}
