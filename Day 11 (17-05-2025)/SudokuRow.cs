using System;
using System.Linq;

namespace Sudoku
{
    internal class SudokuRow
    {
        public static bool ValidateSudokuRow(int[] arr)
        {
            for (int i = 1; i <= 9; i++)
            {
                if (!arr.Contains(i))
                {
                    return false;
                }
            }
            return true;
        }

        public static void Run()
        {
            Console.WriteLine("Please Enter 9 numbers for the Sudoku row:");

            int[] arr = Program.GetArray(9);

            if (ValidateSudokuRow(arr))
                Console.WriteLine("Valid Sudoku Row");
            else
                Console.WriteLine("Invalid Sudoku Row");
        }
    }
}
