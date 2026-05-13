using Microsoft.Data.SqlClient;

namespace TescoClone.Infrastructure.Common;

public static class SqlHelper
{
    public static SqlParameter Input(string name, object? value) =>
        new(name, value ?? DBNull.Value);

    public static SqlParameter InputNullable<T>(string name, T? value) where T : struct =>
        new(name, value.HasValue ? (object)value.Value : DBNull.Value);

    public static async Task<IReadOnlyList<T>> ExecuteReaderAsync<T>(
        SqlConnection connection,
        string storedProcedure,
        Func<SqlDataReader, T> map,
        IEnumerable<SqlParameter>? parameters = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await OpenAndSetupConnectionAsync(connection, cancellationToken);
            using var command = BuildCommand(connection, storedProcedure, parameters);
            using var reader = await command.ExecuteReaderAsync(cancellationToken);
            var results = new List<T>();
            while (await reader.ReadAsync(cancellationToken))
                results.Add(map(reader));
            return results;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error executing reader for stored procedure: {storedProcedure}", ex);
        }
    }

    public static async Task<T?> ExecuteReaderSingleAsync<T>(
        SqlConnection connection,
        string storedProcedure,
        Func<SqlDataReader, T> map,
        IEnumerable<SqlParameter>? parameters = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await OpenAndSetupConnectionAsync(connection, cancellationToken);
            using var command = BuildCommand(connection, storedProcedure, parameters);
            using var reader = await command.ExecuteReaderAsync(cancellationToken);
            return await reader.ReadAsync(cancellationToken) ? map(reader) : default;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error executing single reader for stored procedure: {storedProcedure}", ex);
        }
    }

    public static async Task<int> ExecuteScalarAsync(
        SqlConnection connection,
        string storedProcedure,
        IEnumerable<SqlParameter>? parameters = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await OpenAndSetupConnectionAsync(connection, cancellationToken);
            using var command = BuildCommand(connection, storedProcedure, parameters);
            var result = await command.ExecuteScalarAsync(cancellationToken);
            return Convert.ToInt32(result, System.Globalization.CultureInfo.InvariantCulture);
        }
        catch (Exception ex)
        {
            throw new Exception($"Error executing scalar for stored procedure: {storedProcedure}", ex);
        }
    }

    public static async Task ExecuteNonQueryAsync(
        SqlConnection connection,
        string storedProcedure,
        IEnumerable<SqlParameter>? parameters = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await OpenAndSetupConnectionAsync(connection, cancellationToken);
            using var command = BuildCommand(connection, storedProcedure, parameters);
            await command.ExecuteNonQueryAsync(cancellationToken);
        }
        catch (Exception ex)
        {
            throw new Exception($"Error executing non-query for stored procedure: {storedProcedure}", ex);
        }
    }

    public static T GetValue<T>(SqlDataReader reader, string column) =>
        reader[column] == DBNull.Value ? default! : (T)reader[column];

    public static T? GetNullableValue<T>(SqlDataReader reader, string column) where T : struct =>
        reader[column] == DBNull.Value ? null : (T?)reader[column];

    public static string? GetNullableString(SqlDataReader reader, string column) =>
        reader[column] == DBNull.Value ? null : (string)reader[column];

    private static async Task OpenAndSetupConnectionAsync(SqlConnection connection, CancellationToken cancellationToken)
    {
        await connection.OpenAsync(cancellationToken);
        using var command = new SqlCommand("SET QUOTED_IDENTIFIER ON;", connection);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static SqlCommand BuildCommand(
        SqlConnection connection,
        string storedProcedure,
        IEnumerable<SqlParameter>? parameters)
    {
        var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = storedProcedure;
        if (parameters != null)
            command.Parameters.AddRange(parameters.ToArray());
        return command;
    }
}
