[ApiController]
[Route("api/ddns")]
public class DdnsController : ControllerBase
{
    private readonly IDdnsUpdateService _service;

    public DdnsController(IDdnsUpdateService service)
    {
        _service = service;
    }

    [HttpPost("update")]
    public async Task<IActionResult> UpdateRecord([FromBody] DdnsUpdateRequest request)
    {
        var result = await _service.UpdateAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
