import sys

# Format Should be: "key:name"

args = sys.argv

description = str(args[1])

options = []
keys = []
names = []

# Parse args
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


print("========================================================")
print("")
print(description)
print("")
index = 0
for name in names:
  print(index + ") " + name)
  index = index + 1
print("")
print("========================================================")
input = input("Options(0" + index + ")")
print("========================================================")

print(keys[input])