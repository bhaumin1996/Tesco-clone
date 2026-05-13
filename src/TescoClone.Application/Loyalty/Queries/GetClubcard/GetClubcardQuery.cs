using MediatR;
using TescoClone.Application.Loyalty.DTOs;

namespace TescoClone.Application.Loyalty.Queries.GetClubcard;

public sealed record GetClubcardQuery(int UserId) : IRequest<ClubcardDto?>;
