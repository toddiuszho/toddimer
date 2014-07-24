git() {
  cmd="$1"
  shift 1
  case "$cmd" in
    submit) cmd=commit
  esac

  declare -a margs=()
  for oarg in "$@"; do
    case "$cmd" in
      commit)
        case "$oarg" in
          -d) margs+=("-m");;
          *) margs+=("$oarg");;
        esac;;
      *) margs+=("$oarg");;
    esac
  done

#  echo git $cmd ${margs[@]}
  /bin/git "$cmd" "${margs[@]}"
}

