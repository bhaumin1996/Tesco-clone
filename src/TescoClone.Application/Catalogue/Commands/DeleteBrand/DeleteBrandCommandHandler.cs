using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.DeleteBrand;

public sealed class DeleteBrandCommandHandler : IRequestHandler<DeleteBrandCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public DeleteBrandCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public async Task Handle(DeleteBrandCommand request, CancellationToken cancellationToken)
    {
        await _adminCatalogueRepository.SoftDeleteBrandAsync(request.BrandId, request.AdminUserId, cancellationToken);
    }
}
