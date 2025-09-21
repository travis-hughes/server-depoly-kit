import sys, subprocess

# Format Should be: "key:name"

args = sys.argv

description = str(args[1])

options = []
keys = []
names = []

# Parse arg options
for arg in args:
  # If arg does not contain ":", skip adding.
  if ":" not in arg: 
    continue
  
  options.append(arg)

# Get keys
for option in options:
  keys.append(option.split(":")[0])

# Get names
for option in options:
  names.append(option.split(":")[1])

subprocess.Popen("========================================================", shell=True)
subprocess.Popen("", shell=True)
subprocess.Popen(description, shell=True)
subprocess.Popen("", shell=True)
index = 0
for name in names:
  subprocess.Popen(str(index) + ") " + name, shell=True)
  index = index + 1
subprocess.Popen("", shell=True)
subprocess.Popen("========================================================", shell=True)
input = input("Option (0" + str(index) + "): ")
subprocess.Popen("========================================================", shell=True)

print(keys[input])