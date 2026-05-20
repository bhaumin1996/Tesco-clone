using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.ApplyAsSeller;

public sealed class ApplyAsSellerCommandHandler : IRequestHandler<ApplyAsSellerCommand, int>
{
    private readonly IMarketplaceRepository _repository;
    private readonly IUserRepository _userRepository;
    private readonly IPasswordService _passwordService;

    public ApplyAsSellerCommandHandler(
        IMarketplaceRepository repository,
        IUserRepository userRepository,
        IPasswordService passwordService)
    {
        _repository = repository;
        _userRepository = userRepository;
        _passwordService = passwordService;
    }

    public async Task<int> Handle(ApplyAsSellerCommand request, CancellationToken cancellationToken)
    {
        int userId = request.UserId;

        if (userId <= 0)
        {
            var existingUser = await _userRepository.GetByEmailAsync(request.Dto.BusinessEmail, cancellationToken);
            if (existingUser != null)
            {
                userId = existingUser.Id;
            }
            else
            {
                string contactName = request.Dto.ContactName ?? "Tesco Seller";
                string firstName = contactName;
                string lastName = "Seller";
                int spaceIndex = contactName.IndexOf(' ');
                if (spaceIndex > 0)
                {
                    firstName = contactName.Substring(0, spaceIndex);
                    lastName = contactName.Substring(spaceIndex + 1);
                }

                var passwordHash = _passwordService.Hash("TescoSeller123!");
                var user = TescoClone.Domain.Identity.User.Create(
                    firstName,
                    lastName,
                    request.Dto.BusinessEmail,
                    passwordHash,
                    request.Dto.Phone);

                userId = await _userRepository.CreateAsync(user, passwordHash, cancellationToken);
            }
        }

        var applicationId = await _repository.ApplyAsSellerAsync(userId, request.Dto, cancellationToken);
        await _repository.SubmitApplicationAsync(applicationId, userId, cancellationToken);
        return applicationId;
    }
}
