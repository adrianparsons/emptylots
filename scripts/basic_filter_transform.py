# %%
import pandas as pd
import argparse

def clean_data(df):
    # Rename column 'xcoord' to 'x'
    df = df.rename(columns={'xcoord': 'x'})
    # Rename column 'ycoord' to 'y'
    df = df.rename(columns={'ycoord': 'y'})
    # Drop rows with missing data in column: 'latitude'
    df = df.dropna(subset=['latitude'])

    # Derive column 'state' from column: 'address'
    df.insert(15, 'state', df.apply(lambda row : "", axis=1))
    # Replace all instances of "" with "NY" in column: 'state'
    df.loc[df['state'] == "", 'state'] = "NY"
    # Clone column 'state' as 'city'
    df['city'] = df.loc[:, 'state']

    # TODO: we may want to change the city based on borough
    # Replace all instances of "NY" with "New York" in column: 'city'
    df.loc[df['city'] == "NY", 'city'] = "New York"

    # Drop empty or NA values for column: 'address'
    df = df.dropna(subset=['address'])

    # Drop duplicate rows in column: 'address'
    df = df.drop_duplicates(subset=['address'])
    # Filter rows with addresses that don't start with a number
    df = df[df['address'].str.match(r'[0-9].*')]
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
