if [[ $(flutter format -n .) ]]; then
    exit 1
else
    exit 0
fi