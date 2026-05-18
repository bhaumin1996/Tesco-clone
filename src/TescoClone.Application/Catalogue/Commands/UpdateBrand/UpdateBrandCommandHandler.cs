using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.UpdateBrand;

public sealed class UpdateBrandCommandHandler : IRequestHandler<UpdateBrandCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public UpdateBrandCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public async Task Handle(UpdateBrandCommand request, CancellationToken cancellationToken)
    {
        await _adminCatalogueRepository.UpdateBrandAsync(
            request.BrandId,
            request.Name,
            request.Slug,
            request.LogoUrl,
            request.AdminUserId,
            cancellationToken);
    }
}
