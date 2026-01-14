public class DdnsUpdateService : IDdnsUpdateService
{
    private readonly IDnsProvider _dns;
    private readonly DdnsDbContext _db;

    public DdnsUpdateService(IDnsProvider dns, DdnsDbContext db)
    {
        _dns = dns;
        _db = db;
    }

    public async Task<DdnsUpdateResult> UpdateAsync(DdnsUpdateRequest request)
    {
        var domain = await _db.Domains
            .Where(d => d.Fqdn == request.Fqdn)
            .FirstOrDefaultAsync();

        if (domain == null)
            return DdnsUpdateResult.Fail("Domain not found");

        await _dns.UpdateRecordAsync(domain, request.IpAddress);

        return DdnsUpdateResult.Success();
    }
}
