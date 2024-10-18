# %%
import pandas as pd
import argparse
import json
import math

def json_data(df):
    jsoned = df.to_json(orient='records')
    return jsoned

def dict_data(df):
    dictify = df.to_dict(orient='records')
    constructed = {
        "type": "FeatureCollection",
        "features": []
    }

    for record in dictify:
        newRecord = {"type": "Feature",
                     "geometry": {
                         "type": "Point",
                         "coordinates": [record["longitude"], record["latitude"]]
                     },
                    "properties": {key: val for key, val in record.items() if key not in ["lattitude", "longitude"] and not pd.isna(val)} 
                     }
        constructed["features"].append(newRecord)

    return constructed


def main():
    parser = argparse.ArgumentParser(description='Transform CSV to GeoJSON')
    parser.add_argument('input_file', type=str, help='Path to the input CSV file')
    parser.add_argument('--output_file', type=str, help='Path to the output GeoJSON file', default='output.json')
    args = parser.parse_args()

    df = pd.read_csv(args.input_file)
    dicted = dict_data(df.copy())

    with open(args.output_file, mode="w", encoding="utf-8") as f:
        f.write(json.dumps(dicted, indent=4))

if __name__ == '__main__':
    main()
