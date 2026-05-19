using MediatR;
using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Queries.GetUserRatingStatus;

public sealed record GetUserRatingStatusQuery(int ProductId, int UserId) : IRequest<UserRatingStatusDto>;
