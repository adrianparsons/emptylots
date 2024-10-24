# %%
import pandas as pd
import argparse

def main():
    parser = argparse.ArgumentParser(description='Split CSV into smaller CSVs by borough')
    parser.add_argument('input_file', type=str, help='Path to the input CSV file')
    parser.add_argument('--output_prefix', type=str, help='prefix for output files', default='vacant_borough_')
    args = parser.parse_args()

    df = pd.read_csv(args.input_file)
    grouped = df.groupby("borough")
    boroughs = grouped.groups.keys()

    for b in boroughs:
        g = grouped.get_group(b)
        g.to_csv(args.output_prefix + "_" + b + ".csv", index=False)

if __name__ == '__main__':
    main()


