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
        await _adminCatalogueRepository.UpdateCategoryAsync(
            request.CategoryId,
            request.Name,
            request.DepartmentId,
            request.AdminUserId,
            cancellationToken);
    }
}
