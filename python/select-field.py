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

def echo(text):
  subprocess.run("echo " + text, shell=True)

# TODO: Echo here instead
echo("========================================================")
echo("")
echo(description)
echo("")
index = 0
for name in names:
  echo(str(index) + ") " + name)
  index = index + 1
echo("")
echo("========================================================")
input = input("Option (0" + str(index) + "): ")
echo("========================================================")

print(keys[int])