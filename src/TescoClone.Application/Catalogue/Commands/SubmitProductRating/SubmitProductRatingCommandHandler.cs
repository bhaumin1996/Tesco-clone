using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.SubmitProductRating;

public sealed class SubmitProductRatingCommandHandler(IProductRatingRepository ratingRepository)
    : IRequestHandler<SubmitProductRatingCommand>
{
    public async Task Handle(SubmitProductRatingCommand request, CancellationToken cancellationToken)
        => await ratingRepository.SubmitRatingAsync(request.ProductId, request.UserId, request.Rating, cancellationToken);
}
