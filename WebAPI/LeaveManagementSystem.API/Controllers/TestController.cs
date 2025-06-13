using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace LeaveManagementSystem.Controllers
{
    [ApiController]
    [Route("api/v1/test")]
    public class TestController : ControllerBase
    {
        [HttpGet("ping")]
        public IActionResult Ping()
        {
            return Ok(new
            {
                success = true,
                message = "API is working!"
            });
        }

        [Authorize]
        [HttpGet("secure")]
        public IActionResult Secure()
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value;
            var role = User.FindFirst(ClaimTypes.Role)?.Value;

            return Ok(new
            {
                success = true,
                message = "You are authenticated!",
                email,
                role
            });
        }

        [Authorize(Roles = "HR")]
        [HttpGet("hr-only")]
        public IActionResult HrOnly()
        {
            return Ok(new
            {
                success = true,
                message = "You are HR, welcome!"
            });
        }
    }
}
