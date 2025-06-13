using System.ComponentModel.DataAnnotations;

namespace LeaveManagementSystem.DTOs.Leave
{
    public class LeaveApprovalDto
    {
        [Required]
        public required string Status { get; set; } // Should be "Approved" or "Rejected"
    }
}
