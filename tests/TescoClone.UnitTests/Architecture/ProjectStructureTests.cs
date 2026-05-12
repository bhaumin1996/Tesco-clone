using System.Reflection;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Domain.Common;

namespace TescoClone.UnitTests.Architecture;

public sealed class ProjectStructureTests
{
    private static readonly Assembly _domainAssembly = typeof(Entity).Assembly;
    private static readonly Assembly _applicationAssembly = typeof(IClock).Assembly;

    [Fact]
    public void Domain_ShouldNotReference_ApplicationAssembly()
    {
        var refs = _domainAssembly.GetReferencedAssemblies().Select(a => a.Name);
        Assert.DoesNotContain("TescoClone.Application", refs);
    }

    [Fact]
    public void Domain_ShouldNotReference_InfrastructureAssembly()
    {
        var refs = _domainAssembly.GetReferencedAssemblies().Select(a => a.Name);
        Assert.DoesNotContain("TescoClone.Infrastructure", refs);
    }

    [Fact]
    public void Domain_ShouldNotReference_ApiAssembly()
    {
        var refs = _domainAssembly.GetReferencedAssemblies().Select(a => a.Name);
        Assert.DoesNotContain("TescoClone.API", refs);
    }

    [Fact]
    public void Application_ShouldNotReference_InfrastructureAssembly()
    {
        var refs = _applicationAssembly.GetReferencedAssemblies().Select(a => a.Name);
        Assert.DoesNotContain("TescoClone.Infrastructure", refs);
    }

    [Fact]
    public void Application_ShouldNotReference_ApiAssembly()
    {
        var refs = _applicationAssembly.GetReferencedAssemblies().Select(a => a.Name);
        Assert.DoesNotContain("TescoClone.API", refs);
    }
}
