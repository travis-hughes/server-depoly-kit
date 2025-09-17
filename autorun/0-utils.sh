input_field()
{
  FIELD_NAME=$1

  read -p "$FIELD_NAME: " OUTPUT
  if [ -z "$OUTPUT" ]; then
    echo "$FIELD_NAME is empty"
    exit 1
  fi

  echo "$OUTPUT" > deploy.env
  echo "$OUTPUT"
}

ensure_var_defined()
{
  Label=$1
  INPUT=$2

  if [ -z "$INPUT" ]; then
    INPUT=$( input_field $Label )
  else
    echo "$Label already defined, skipping step..."
  fi

  echo "$INPUT"
}