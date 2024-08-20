import csv
from collections import defaultdict

# Fill the gaps in the correspondence data
def fill_gaps_in_correspondence(input_csv, output_csv):
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

            # Merge duplicate rows by summing their weights
            correspondences[(source, source_id, target, target_id)][year] += weight

    # Create output CSV data
    filled_data = {}
    items_to_add = []  # Collect items to add after the main loop
    for (source, source_id, target, target_id), years in list(correspondences.items()):
        # Check for reverse direction in the correspondence
        reverse_key = (target, target_id, source, source_id)
        for year in years:
            forward_weight = years[year]
            reverse_weight = correspondences[reverse_key].get(year, 0)
            max_weight = max(forward_weight, reverse_weight)

            forward_key = (source, source_id, target, target_id, year)
            reverse_key = (target, target_id, source, source_id, year)

            # Add or update the forward correspondence
            filled_data[forward_key] = {
                'Source': source,
                'SourceID': source_id,
                'Target': target,
                'TargetID': target_id,
                'Year': year,
                'Type': 'Directed',
                'Label': f'{source} an {target}, {year}',
                'Weight': max_weight
            }

            # Ensure reverse correspondence is also recorded
            if reverse_weight < max_weight:
                items_to_add.append({
                    'key': reverse_key,
                    'data': {
                        'Source': target,
                        'SourceID': target_id,
                        'Target': source,
                        'TargetID': source_id,
                        'Year': year,
                        'Type': 'Directed',
                        'Label': f'{target} an {source}, {year}',
                        'Weight': max_weight
                    }
                })

    # Add the collected items after the main loop
    for item in items_to_add:
        filled_data[item['key']] = item['data']

    # Write the output CSV file
    with open(output_csv, mode='w', newline='', encoding='utf-8') as outfile:
        fieldnames = ['Source', 'SourceID', 'Target', 'TargetID', 'Year', 'Type', 'Label', 'Weight']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(filled_data.values())

# Paths
input_csv = 'jung-wien-ist.csv'
output_csv = 'jung-wien-without-gaps.csv'
fill_gaps_in_correspondence(input_csv, output_csv)
