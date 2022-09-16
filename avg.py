from io import StringIO
import subprocess
import sys

import pandas as pd
import numpy as np

pd.set_option('display.precision', 3)

def die(msg):
    print(msg, file=sys.stderr)
    exit(1)

def run_once():
    result = subprocess.run('./time-tests.sh', stdout=subprocess.PIPE, text=True)
    if result.returncode != 0:
        die("Failed to run test")
    if len(result.stdout) == 0:
        die("Failed to obtain test stdout")
    return result.stdout

def run_many(count):
    if count < 1:
        die("Count must be greater than or equal to 1")
    return [run_once() for _ in range(count)]

def mean(df_list):
    df = pd.concat(df_list)
    result = df.groupby('name', as_index=False).mean()
    return result.to_csv(index=False, float_format="%.3f")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        die("usage: python avg.py <count>")
    count = int(sys.argv[1])
    data = run_many(count)
    # print(data)
    df_list = [ pd.read_table(StringIO(datum), dtype={'name': str, 'time': np.float64, 'status': bool}) for datum in data ]
    # print(df_list)
    proc_res = mean(df_list)
    print(proc_res)
