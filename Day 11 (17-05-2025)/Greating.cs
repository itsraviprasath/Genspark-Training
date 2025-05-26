using System;

namespace Greet
{
    internal class Greetings
    {
        public static void Run()
        {
            Console.Write("Please enter your name: ");
            string userName = Console.ReadLine();
            Console.WriteLine($"Hello {userName}, welcome to our page!");
        }
    }
}
