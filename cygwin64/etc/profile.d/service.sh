service() {
  local svc="$1"
  local action="$2"
  case "${svc}" in
    mysqld) svc="MySQL55"
  esac
  net "${action}" "${svc}"
}

