import pandas as pd
import sys

# file has 4 columns
names = ['a', 'b', 'c', 'd']
df = pd.read_csv(sys.argv[1], sep='\t', header=None, names=names)
# groupby first column and print remainingg 3 columns each as list:
df1 = df.groupby('a', as_index=False).agg(list)
df2 = df1.to_string(index=False, header=False)

if df.empty:
    pass
else:
    print(df2)

