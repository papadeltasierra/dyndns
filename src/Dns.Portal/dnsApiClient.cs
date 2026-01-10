public class DdnsApiClient : IDdnsApiClient
{
    private readonly HttpClient _http;

    public DdnsApiClient(HttpClient http)
    {
        _http = http;
    }

    public async Task<List<DomainDto>> GetDomainsAsync()
    {
        return await _http.GetFromJsonAsync<List<DomainDto>>("api/domains")
               ?? new List<DomainDto>();
    }
}
