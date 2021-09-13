#import pandas as pd
import sys
import csv

with open(sys.argv[1], 'r') as f:
    reader = csv.reader(f, delimiter='\t')
    for line in reader:
        print(line)


