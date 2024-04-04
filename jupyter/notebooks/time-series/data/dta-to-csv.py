#!/usr/bin/python
import pandas as pd

# Prompting user for input file name
input_file = input("Enter the input file name (Stata .dta file): ")

# Prompting user for output file name
output_file = input("Enter the output file name (CSV): ")

# Read Stata file
try:
    data = pd.read_stata(input_file)
except FileNotFoundError:
    print("Error: Input file not found.")
    exit()

# Write to CSV
data.to_csv(output_file, index=False)

print("Conversion complete.")

