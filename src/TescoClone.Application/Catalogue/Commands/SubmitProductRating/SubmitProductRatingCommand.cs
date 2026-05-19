using MediatR;

namespace TescoClone.Application.Catalogue.Commands.SubmitProductRating;

public sealed record SubmitProductRatingCommand(int ProductId, int UserId, int Rating) : IRequest;
