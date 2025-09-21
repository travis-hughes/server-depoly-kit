# Sync files.txt

import urllib.request, os, sys

base_url="http://www.example.com/"
temp_data_path="/srv/deploy_tmp"

# Retrieve fs files
urllib.request.urlretrieve(base_url + "files.txt", temp_data_path + "files.txt")

# Open file
with open(temp_data_path + "files.txt", 'r') as file:
    file_paths = file.readlines()

# Loop over ea ch url inside and download file
for file_path in file_paths:
    output_dir = temp_data_path + file_path
    os.makedirs(os.path.dirname(output_dir), exist_ok=True)
    urllib.request.urlretrieve(base_url + file_path, output_dir)