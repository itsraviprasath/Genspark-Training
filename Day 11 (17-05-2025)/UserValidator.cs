using System;

namespace User
{
    public class User_Validator
    {
        private static bool ValidateCredentials(string username, string password)
        {
            return string.Equals(username, "Admin") && string.Equals(password, "test123");
        }

        public static void Run()
        {
            int attemptsRemaining = 3;

            while (attemptsRemaining > 0)
            {
                Console.Write("Please Enter username: ");
                string username = Program.GetStringInput();

                Console.Write("Please Enter password: ");
                string password = Program.GetStringInput();

                if (ValidateCredentials(username, password))
                {
                    Console.WriteLine("Login successful. Welcome!");
                    return;
                }
                else
                {
                    attemptsRemaining--;
                    Console.WriteLine($"Invalid credentials. Attempts remaining: {attemptsRemaining}");
                }
            }

            Console.WriteLine("Too many failed attempts. Access denied.");
        }
    }
}
