public class DdnsUpdateServiceTests
{
    [Fact]
    public async Task UpdateAsync_ReturnsFail_WhenDomainMissing()
    {
        // Arrange
        var service = new DdnsUpdateService(
            Substitute.For<IDnsProvider>(),
            TestDbContext.Empty()
        );

        // Act
        var result = await service.UpdateAsync(new DdnsUpdateRequest
        {
            Fqdn = "missing.example.com",
            IpAddress = "1.2.3.4"
        });

        // Assert
        Assert.False(result.Success);
    }
}
