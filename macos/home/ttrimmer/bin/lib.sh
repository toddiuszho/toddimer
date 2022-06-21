scm_prompt ()
{
    local CHAR;
    CHAR="$(scm_char)";
    local format=${SCM_PROMPT_FORMAT:-'[%s%s]'};
    if [[ "${CHAR}" != "$SCM_NONE_CHAR" ]]; then
        printf "$format\n" "$CHAR" "$(scm_prompt_info)";
    fi
}
