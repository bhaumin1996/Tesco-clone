using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.DeleteDepartment;

public sealed class DeleteDepartmentCommandHandler : IRequestHandler<DeleteDepartmentCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public DeleteDepartmentCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public async Task Handle(DeleteDepartmentCommand request, CancellationToken cancellationToken)
    {
        await _adminCatalogueRepository.SoftDeleteDepartmentAsync(request.DepartmentId, request.AdminUserId, cancellationToken);
    }
}
