using System.ComponentModel.DataAnnotations;

namespace LeaveManagementSystem.Models
{
    public class User
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public required string Username { get; set; }

        [Required]
        public required string Email { get; set; }

        [Required]
        public required string PasswordHash { get; set; }

        [Required]
        public required string Role { get; set; }  // HR or Employee

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
