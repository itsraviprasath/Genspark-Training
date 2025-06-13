using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LeaveManagementSystem.Models
{
    public class LeaveRequest : BaseEntity
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid EmployeeId { get; set; }

        [ForeignKey("EmployeeId")]
        public required User Employee { get; set; }

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        [Required]
        public required string Reason { get; set; }

        public string? AttachmentPath { get; set; }

        public string Status { get; set; } = "Pending"; // "Pending", "Approved", "Rejected"

        public new DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
