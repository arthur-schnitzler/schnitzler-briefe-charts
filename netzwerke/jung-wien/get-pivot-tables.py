import pandas as pd
import os

# CSV file paths
files = [
    'jung-wien-alle-without-gaps.csv',
    'jung-wien-ist-alle.csv'
]

# Output directory
output_dir = 'pivot-tables'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Function to create a standardized column for each correspondence
def standardize_correspondence(row):
    source_target = sorted([f"{row['Source']}", f"{row['Target']}"])
    return f"{source_target[0]} – {source_target[1]}"

# Function to create and save the pivot table
def create_and_save_pivot_table(file_path):
    # Read the CSV file with header
    df = pd.read_csv(file_path, header=0)
    
    # Create a standardized correspondence column
    df['Correspondence'] = df.apply(standardize_correspondence, axis=1)
    
    # Group by Year and Correspondence, summing the Weight
    pivot_df = df.pivot_table(
        index='Year',
        columns='Correspondence',
        values='Weight',
        aggfunc='sum',
        fill_value=0
    )
    
    # Generate output file name
    base_name = os.path.basename(file_path)
    output_file = os.path.join(output_dir, os.path.splitext(base_name)[0] + '_pivot.xlsx')
    
    # Save the pivot table to an Excel file
    with pd.ExcelWriter(output_file, engine='xlsxwriter') as writer:
        pivot_df.to_excel(writer, sheet_name='Pivot Table')
    
    print(f'Pivot table created and saved to {output_file}')

# Process each file
for file in files:
    create_and_save_pivot_table(file)

print('All pivot tables have been created and saved.')
