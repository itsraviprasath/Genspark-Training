using LeaveManagementSystem.Models;

namespace LeaveManagementSystem.Services
{
    public interface IJwtService
    {
        string GenerateToken(User user);
    }
}
