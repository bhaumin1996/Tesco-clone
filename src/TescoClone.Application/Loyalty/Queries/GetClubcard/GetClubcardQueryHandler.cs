using MediatR;
using TescoClone.Application.Loyalty.DTOs;
using TescoClone.Application.Loyalty.Interfaces;

namespace TescoClone.Application.Loyalty.Queries.GetClubcard;

public sealed class GetClubcardQueryHandler : IRequestHandler<GetClubcardQuery, ClubcardDto?>
{
    private readonly ILoyaltyRepository _loyaltyRepository;

    public GetClubcardQueryHandler(ILoyaltyRepository loyaltyRepository)
    {
        _loyaltyRepository = loyaltyRepository;
    }

    public Task<ClubcardDto?> Handle(GetClubcardQuery request, CancellationToken cancellationToken) =>
        _loyaltyRepository.GetByUserIdAsync(request.UserId, cancellationToken);
}
