using System;
using System.Collections.Generic;

namespace Frequency
{
    internal class FrequencyCount
    {
        public static void PrintFrequency(Dictionary<int, int> frequencyMap)
        {
            Console.WriteLine("\nFrequency of each number:");
            foreach (var entry in frequencyMap)
            {
                Console.WriteLine($"Number {entry.Key} occurs {entry.Value} time(s).");
            }
        }

        private static Dictionary<int, int> CountFrequency(int[] array, Dictionary<int, int> frequencyMap)
        {
            foreach (int number in array)
            {
                if (frequencyMap.ContainsKey(number))
                {
                    frequencyMap[number]++;
                }
                else
                {
                    frequencyMap[number] = 1;
                }
            }
            return frequencyMap;
        }

        public static void Run()
        {
            Console.Write("Enter the size of the array: ");
            int size = Program.GetNumberInput();

            int[] numbers = Program.GetArray(size);

            Dictionary<int, int> frequencyMap = new Dictionary<int, int>();

            CountFrequency(numbers, frequencyMap);
            PrintFrequency(frequencyMap);
        }
    }
}
