using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetUserRatingStatus;

public sealed class GetUserRatingStatusQueryHandler(IProductRatingRepository ratingRepository)
    : IRequestHandler<GetUserRatingStatusQuery, UserRatingStatusDto>
{
    public async Task<UserRatingStatusDto> Handle(GetUserRatingStatusQuery request, CancellationToken cancellationToken)
        => await ratingRepository.GetUserRatingStatusAsync(request.ProductId, request.UserId, cancellationToken);
}
