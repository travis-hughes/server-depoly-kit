import urllib.request, os, sys

args = sys.argv

base_output_dir = str(args[1])
url = str(args[2])
file = str(args[3])

output_dir = base_output_dir + file
os.makedirs(os.path.dirname(output_dir), exist_ok=True)
urllib.request.urlretrieve(url + file, output_dir)