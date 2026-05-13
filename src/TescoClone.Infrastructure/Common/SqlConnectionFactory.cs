using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace TescoClone.Infrastructure.Common;

public sealed class SqlConnectionFactory
{
    private readonly string _connectionString;

    public SqlConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("Default")
            ?? throw new InvalidOperationException("Connection string 'Default' is not configured.");
    }

    public SqlConnection CreateConnection() => new(_connectionString);
}
