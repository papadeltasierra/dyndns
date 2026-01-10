public interface IDdnsUpdateService
{
    Task<DdnsUpdateResult> UpdateAsync(DdnsUpdateRequest request);
}
