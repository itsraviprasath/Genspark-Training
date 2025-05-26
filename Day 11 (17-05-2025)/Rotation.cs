using System;

namespace Rotate
{
    internal class Rotation
    {
        private static void LeftRotate(int[] array, int rotateBy)
        {
            int size = array.Length;
            int[] rotatedArray = new int[size];

            int index = 0;

            for (int i = rotateBy; i < size; i++)
            {
                rotatedArray[index++] = array[i];
            }

            for (int i = 0; i < rotateBy; i++)
            {
                rotatedArray[index++] = array[i];
            }

            PrintArray(rotatedArray);
        }

        public static void PrintArray(int[] array)
        {
            Console.WriteLine("\nThe rotated array is:");
            foreach (int number in array)
            {
                Console.Write(number + " ");
            }
            Console.WriteLine();
        }

        public static void Run()
        {
            Console.Write("Enter the size of the array: ");
            int size = Program.GetNumberInput();

            int[] array = Program.GetArray(size);

            Console.Write("Enter the number of positions to left-rotate: ");
            int rotations = Program.GetNumberInput();

            if (rotations > 0)
            {
                LeftRotate(array, rotations % size);
            }
            else
            {
                Console.WriteLine("No rotation performed.");
            }
        }
    }
}
