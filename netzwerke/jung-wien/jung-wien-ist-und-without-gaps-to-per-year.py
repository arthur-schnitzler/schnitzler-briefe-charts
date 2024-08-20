import csv
from collections import defaultdict

def transform_csv(input_csv, output_csv):
    # Reading the input CSV data
    correspondences = defaultdict(lambda: defaultdict(int))

    with open(input_csv, mode='r', encoding='utf-8') as infile:
        reader = csv.DictReader(infile)
        for row in reader:
            source = row['Source']
            source_id = row['SourceID']
            target = row['Target']
            target_id = row['TargetID']
            year = row['Year']
            weight = int(row['Weight'])

            # Create an undirected key to sum the weights of both directions
            undirected_key = tuple(sorted([(source, source_id), (target, target_id)]))
            correspondences[undirected_key][year] += weight

    # Create output CSV data
    transformed_data = []
    for (source_tuple, target_tuple), years in correspondences.items():
        source, source_id = source_tuple
        target, target_id = target_tuple

        for year, total_weight in years.items():
            transformed_data.append({
                'Source': source,
                'SourceID': source_id,
                'Target': target,
                'TargetID': target_id,
                'Year': year,
                'Type': 'Undirected',
                'Label': f'{source} – {target}, {year}',
                'Weight': total_weight
            })

    # Write the output CSV file
    with open(output_csv, mode='w', newline='', encoding='utf-8') as outfile:
        fieldnames = ['Source', 'SourceID', 'Target', 'TargetID', 'Year', 'Type', 'Label', 'Weight']
        
        # Write the header manually without quotes
        outfile.write(','.join(fieldnames) + '\n')
        
        # Write the data rows with quotes
        writer = csv.DictWriter(outfile, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        writer.writerows(transformed_data)

# Paths for the CSV files
input_csv_with_gaps = 'jung-wien-ist-alle.csv'
output_csv_with_gaps_transformed = 'jung-wien-ist-alle-per-year.csv'

input_csv_without_gaps = 'jung-wien-alle-without-gaps.csv'
output_csv_without_gaps_transformed = 'jung-wien-alle-without-gaps-per-year.csv'

# Transform the CSV files
transform_csv(input_csv_with_gaps, output_csv_with_gaps_transformed)
transform_csv(input_csv_without_gaps, output_csv_without_gaps_transformed)
