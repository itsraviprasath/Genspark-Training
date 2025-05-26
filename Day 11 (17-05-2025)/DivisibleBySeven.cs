using System;

namespace Divisible
{
    public class DivisibleBySeven
    {
        public static void Run()
        {
            int totalInputs = 10;
            int divisibleCount = CountDivisibleBySeven(totalInputs);

            Console.WriteLine($"Total numbers divisible by 7: {divisibleCount}");
        }

        public static int ReadNumber(int index)
        {
            Console.Write($"Enter number #{index}: ");
            return Convert.ToInt32(Console.ReadLine());
        }

        public static bool IsDivisibleBySeven(int number)
        {
            return number % 7 == 0;
        }

        public static int CountDivisibleBySeven(int total)
        {
            int count = 0;
            for (int i = 1; i <= total; i++)
            {
                int input = ReadNumber(i);
                if (IsDivisibleBySeven(input))
                {
                    count++;
                }
            }
            return count;
        }
    }
}
