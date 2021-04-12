echo "hello" | cat "notFound" | cat -n
echo "shouldn't be executed: $?"

