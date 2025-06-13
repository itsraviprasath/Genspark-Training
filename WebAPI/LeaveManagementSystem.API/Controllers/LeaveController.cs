using LeaveManagementSystem.Data;
using LeaveManagementSystem.DTOs.Leave;
using LeaveManagementSystem.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace LeaveManagementSystem.Controllers
{
    [ApiController]
    [Route("api/v1/leave")]
    public class LeaveController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _env;

        public LeaveController(ApplicationDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        [Authorize(Roles = "Employee")]
        [HttpPost("apply")]
        public async Task<IActionResult> ApplyLeave([FromForm] LeaveRequestDto dto)
        {
            var employeeId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            string? filePath = null;
            if (dto.Attachment != null)
            {
                var uploads = Path.Combine(_env.WebRootPath ?? "wwwroot", "attachments");
                Directory.CreateDirectory(uploads);

                var fileName = Guid.NewGuid() + Path.GetExtension(dto.Attachment.FileName);
                filePath = Path.Combine("attachments", fileName);

                var fullPath = Path.Combine(uploads, fileName);
                using var stream = new FileStream(fullPath, FileMode.Create);
                await dto.Attachment.CopyToAsync(stream);
            }

            var employee = await _context.Users.FindAsync(Guid.Parse(employeeId));
            if (employee == null)
            {
                return BadRequest(new { success = false, message = "Employee not found." });
            }

            var leave = new LeaveRequest
            {
                Id = Guid.NewGuid(),
                EmployeeId = Guid.Parse(employeeId),
                Employee = employee,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                Reason = dto.Reason,
                AttachmentPath = filePath
            };

            _context.LeaveRequests.Add(leave);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Leave applied successfully"
            });
        }

        // Get all leave requests for HR
        [Authorize(Roles = "HR")]
        [HttpGet("all")]
        public IActionResult GetAllLeaves([FromQuery] string? status, int page = 1, int pageSize = 10)
        {
            var query = _context.LeaveRequests.AsQueryable();

            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(l => l.Status == status);
            }

            var totalRecords = query.Count();

            var leaves = query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(l => new
                {
                    l.Id,
                    l.StartDate,
                    l.EndDate,
                    l.Reason,
                    l.Status,
                    l.AttachmentPath,
                    EmployeeName = l.Employee.Username
                })
                .ToList();

            return Ok(new
            {
                success = true,
                data = leaves,
                pagination = new
                {
                    totalRecords,
                    page,
                    pageSize,
                    totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize)
                }
            });
        }


        [Authorize(Roles = "HR")]
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateLeaveStatus(Guid id, [FromBody] LeaveApprovalDto dto)
        {
            var validStatuses = new[] { "Approved", "Rejected" };

            if (!validStatuses.Contains(dto.Status))
            {
                return BadRequest(new
                {
                    success = false,
                    message = "Invalid status. Must be 'Approved' or 'Rejected'"
                });
            }

            var leave = await _context.LeaveRequests.FindAsync(id);

            if (leave == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Leave request not found"
                });
            }

            if (leave.Status != "Pending")
            {
                return BadRequest(new
                {
                    success = false,
                    message = "Leave request is already processed"
                });
            }

            leave.Status = dto.Status;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = $"Leave request has been {dto.Status.ToLower()}"
            });
        }

        [Authorize(Roles = "HR")]
        [HttpGet("download/{filename}")]
        public IActionResult DownloadAttachment(string filename)
        {
            var uploadsFolder = Path.Combine(_env.WebRootPath ?? "wwwroot", "attachments");
            var filePath = Path.Combine(uploadsFolder, filename);

            if (!System.IO.File.Exists(filePath))
            {
                return NotFound(new
                {
                    success = false,
                    message = "File not found"
                });
            }

            var mimeType = "application/octet-stream";
            return PhysicalFile(filePath, mimeType, filename);
        }

    }
}
