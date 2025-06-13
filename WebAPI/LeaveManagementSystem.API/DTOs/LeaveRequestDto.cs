using System.ComponentModel.DataAnnotations;

namespace LeaveManagementSystem.DTOs.Leave
{
    public class LeaveRequestDto
    {
        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        [Required]
        public required string Reason { get; set; }

        public IFormFile? Attachment { get; set; }
    }
}
