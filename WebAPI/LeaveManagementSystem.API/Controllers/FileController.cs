using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LeaveManagementSystem.Controllers
{
    [Route("api/v1/files")]
    [ApiController]
    public class FileController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;

        public FileController(IWebHostEnvironment env)
        {
            _env = env;
        }

        // POST: api/v1/files/upload
        [HttpPost("upload")]
        [Authorize]
        public async Task<IActionResult> UploadFile(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { success = false, message = "No file uploaded" });

            var fileName = $"{Guid.NewGuid()}_{Path.GetFileName(file.FileName)}";
            var uploadsPath = Path.Combine(_env.ContentRootPath, "Uploads");

            var filePath = Path.Combine(uploadsPath, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            return Ok(new
            {
                success = true,
                message = "File uploaded successfully",
                data = new { fileName, fileUrl = $"/uploads/{fileName}" }
            });
        }

        // GET: api/v1/files/{fileName}
        [HttpGet("{fileName}")]
        [AllowAnonymous]
        public IActionResult DownloadFile(string fileName)
        {
            var uploadsPath = Path.Combine(_env.ContentRootPath, "Uploads");
            var filePath = Path.Combine(uploadsPath, fileName);

            if (!System.IO.File.Exists(filePath))
                return NotFound(new { success = false, message = "File not found" });

            var mimeType = "application/octet-stream";
            return PhysicalFile(filePath, mimeType, fileName);
        }
    }
}
