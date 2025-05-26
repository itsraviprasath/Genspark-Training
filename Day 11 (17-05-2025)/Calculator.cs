using System;

namespace Calc
{
    internal class Calculator
    {
        public static void Run()
        {
            int number1, number2;

            Console.Write("Enter the first number: ");
            number1 = Convert.ToInt32(Console.ReadLine());

            Console.Write("Enter the second number: ");
            number2 = Convert.ToInt32(Console.ReadLine());

            Console.WriteLine("Choose an operation: 1 - Add, 2 - Subtract, 3 - Multiply, 4 - Divide");

            int operation = Convert.ToInt32(Console.ReadLine());

            switch (operation)
            {
                case 1:
                    Console.WriteLine($"Sum: {number1 + number2}");
                    break;
                case 2:
                    Console.WriteLine($"Difference: {number1 - number2}");
                    break;
