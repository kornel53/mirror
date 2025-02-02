using Microsoft.AspNetCore.Mvc;

namespace Mirror.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MirrorController : ControllerBase
    {
        [HttpGet]
        [HttpPost]
        [HttpPut]
        [HttpDelete]
        [HttpPatch]
        public async Task<IActionResult> GetRequestDetails()
        {
            var requestDetails = new
            {
                Method = Request.Method,
                Headers = Request.Headers.ToDictionary(h => h.Key, h => h.Value.ToString()),
                QueryString = Request.QueryString.ToString(),
                Body = await ReadRequestBodyAsync(Request)
            };

            return Ok(requestDetails);
        }

        private static async Task<string> ReadRequestBodyAsync(HttpRequest request)
        {
            request.EnableBuffering();
            using var reader = new StreamReader(request.Body);
            request.Body.Position = 0;
            var body = await reader.ReadToEndAsync();
            request.Body.Position = 0; // Reset the stream position after reading
            return body;
        }
    }
}
