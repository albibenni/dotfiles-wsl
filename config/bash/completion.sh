# Optional CLI integrations from the original setup, initialized once per shell.
if command -v kubectl >/dev/null 2>&1; then
    if ! declare -F __start_kubectl >/dev/null 2>&1; then
        if _dotfiles_completion=$(kubectl completion bash); then
            eval "$_dotfiles_completion"
        fi
        unset _dotfiles_completion
    fi
    if declare -F __start_kubectl >/dev/null 2>&1; then
        complete -o default -F __start_kubectl k
    fi
fi
if command -v try >/dev/null 2>&1 && [[ ${DOTFILES_WSL_TRY_ACTIVE:-0} != 1 ]]; then
    if _dotfiles_completion=$(SHELL=/bin/bash command try init "${DOTFILES_WSL_TRIES_DIR:-$HOME/Work/tries}"); then
        eval "$_dotfiles_completion"
        DOTFILES_WSL_TRY_ACTIVE=1
    fi
    unset _dotfiles_completion
fi
if command -v task-planner >/dev/null 2>&1 && [[ ${DOTFILES_WSL_TASK_PLANNER_ACTIVE:-0} != 1 ]]; then
    if _dotfiles_completion=$(task-planner completion bash); then
        eval "$_dotfiles_completion"
        DOTFILES_WSL_TASK_PLANNER_ACTIVE=1
    fi
    unset _dotfiles_completion
fi
