FLY=/usr/local/bin/fly

fly_architecture() {
  local machine_architecture=${1:-$(uname -m)}

  case "$machine_architecture" in
    x86_64|amd64)
      echo amd64
      ;;
    aarch64|arm64)
      echo arm64
      ;;
    *)
      echo "Unsupported architecture: $machine_architecture" >&2
      return 1
      ;;
  esac
}

fetch_fly() {
  local url=$1
  local insecure=$2
  local architecture

  local insecure_arg=""
  test "$insecure" = "true" && insecure_arg="--insecure"

  if ! [ -x $FLY ]; then
    echo "Fetching fly..."
    architecture=$(fly_architecture) || return 1
    curl -fSsL $insecure_arg "$url/api/v1/cli?arch=$architecture&platform=linux" -o "$FLY"
    chmod +x "$FLY"
  fi
}

login() {
  local url="$1"
  local username="$2"
  local password="$3"
  local team="$4"
  local insecure="$5"
  local target="$6"
  local tried="$7"

  local insecure_arg=""
  test "$insecure" = "true" && insecure_arg="--insecure"

  echo "Logging in..."
  local out=$($FLY login -t "$target" $insecure_arg -c "$url" -n "$team" "--username=$username" "--password=$password" 2>&1)

  # This sucks
  if echo "$out" | grep "fly -t $target sync" > /dev/null; then
    test -n "$tried" && return 1
    fetch_fly "$url" "$insecure"
    login "$url" "$username" "$password" "$team" "$insecure" "$target" yes
  fi
}

init_fly() {
  local url="$1"
  local username="$2"
  local password="$3"
  local team="$4"
  local insecure="$5"
  local target="$6"

  fetch_fly "$url" "$insecure"
  login "$url" "$username" "$password" "$team" "$insecure" "$target"
}
