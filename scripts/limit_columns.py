# %%
import pandas as pd
import argparse

def clean_data(df):
    # Select columns: 'borough', 'Tax block' and 27 other columns
    df = df.loc[:, ['borough', 'Tax block', 'Tax lot', 'community board', 'council district', 'postcode', 'policeprct', 'address', 'state', 'bldgclass', 'landuse', 'ownertype', 'ownername', 'lotarea', 'unitstotal', 'lotfront', 'lotdepth', 'lottype', 'assessland', 'yearbuilt', 'histdist', 'landmark', 'borocode', 'x', 'y', 'latitude', 'longitude', 'zonemap', 'notes', 'city']]
    return df

def main():
    parser = argparse.ArgumentParser(description='Transform raw CSV for use in google maps')
    parser.add_argument('input_file', type=str, help='Path to the input CSV file')
    parser.add_argument('--output_file', type=str, help='Path to the output CSV file', default='output.csv')
    args = parser.parse_args()

    df = pd.read_csv(args.input_file)
    df_clean = clean_data(df.copy())
    df_clean.to_csv(args.output_file, index=False)

if __name__ == '__main__':
    main()


