#!/bin/python3

import math
import os
import random
import re
import sys
from functools import reduce

#
# Complete the 'getTotalX' function below.
#
# The function is expected to return an INTEGER.
# The function accepts following parameters:
#  1. INTEGER_ARRAY a
#  2. INTEGER_ARRAY b
#


def lcm(x, y):
    return x * y // math.gcd(x, y)

# LCM
def lcm_list(lst):
    return reduce(lcm, lst)

# GCD
def gcd_list(lst):
    return reduce(math.gcd, lst)

def getTotalX(a, b):
    # Write your code here
    lcm_a = lcm_list(a)
    gcd_b = gcd_list(b)
    
    count = 0
    multiple = lcm_a
    
    while multiple <= gcd_b:
        if gcd_b % multiple == 0:
            count += 1
        multiple += lcm_a
    
    return count

if __name__ == '__main__':
    fptr = open(os.environ['OUTPUT_PATH'], 'w')

    first_multiple_input = input().rstrip().split()

    n = int(first_multiple_input[0])

    m = int(first_multiple_input[1])

    arr = list(map(int, input().rstrip().split()))

    brr = list(map(int, input().rstrip().split()))

    total = getTotalX(arr, brr)

    fptr.write(str(total) + '\n')

    fptr.close()
