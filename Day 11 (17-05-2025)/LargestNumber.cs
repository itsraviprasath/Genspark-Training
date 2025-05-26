using System;

namespace Largest
{
    public class LargestNumber
    {
        public static void Run()
        {
            int number1, number2;

            Console.Write("Enter the first number: ");
            number1 = Program.GetNumberInput();

            Console.Write("Enter the second number: ");
            number2 = Program.GetNumberInput();

            int largest = Math.Max(number1, number2);
            Console.WriteLine($"The larger number is: {largest}");
        }
    }
}
