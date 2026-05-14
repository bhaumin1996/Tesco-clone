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

    public Task<int> Handle(CreateCategoryCommand request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.CreateCategoryAsync(request.Name, request.DepartmentId, request.AdminUserId, cancellationToken);
}
