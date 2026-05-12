using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace TescoClone.IntegrationTests.Api;

public sealed class HealthEndpointTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public HealthEndpointTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task HealthEndpoint_ShouldReturn200_WhenApplicationIsRunning()
    {
        var response = await _client.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task StatusEndpoint_ShouldReturnReady_WhenApplicationIsRunning()
    {
        var response = await _client.GetAsync("/api/v1/status");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
