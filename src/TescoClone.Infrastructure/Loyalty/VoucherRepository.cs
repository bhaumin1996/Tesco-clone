using TescoClone.Application.Loyalty.DTOs;
using TescoClone.Application.Loyalty.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Loyalty;

public sealed class VoucherRepository : IVoucherRepository
{
    private readonly SqlConnectionFactory _connectionFactory;

    public VoucherRepository(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<VoucherDto>> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Loyalty_GetVouchersByUserId",
            MapVoucher,
            [SqlHelper.Input("@UserId", userId)],
            cancellationToken);
    }

    public async Task<VoucherDto?> GetByCodeAsync(int userId, string code, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Loyalty_GetVoucherByCode",
            MapVoucher,
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@Code", code),
            ],
            cancellationToken);
    }

    public async Task RedeemAsync(int userId, string code, int orderId, int modifiedBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Loyalty_RedeemVoucher",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@Code", code),
                SqlHelper.Input("@OrderId", orderId),
                SqlHelper.Input("@ModifiedBy", modifiedBy),
            ],
            cancellationToken);
    }

    private static VoucherDto MapVoucher(Microsoft.Data.SqlClient.SqlDataReader reader) =>
        new(
            SqlHelper.GetValue<int>(reader, "Id"),
            SqlHelper.GetValue<string>(reader, "Code"),
            SqlHelper.GetValue<decimal>(reader, "DiscountAmount"),
            SqlHelper.GetNullableValue<decimal>(reader, "MinimumSpend"),
            SqlHelper.GetValue<DateTime>(reader, "ValidFrom"),
            SqlHelper.GetValue<DateTime>(reader, "ValidTo"),
            SqlHelper.GetValue<bool>(reader, "IsRedeemed"));
}
