
set -e
# Source: https://github.com/sharkdp/bat

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo apt install -y bat
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    brew install bat
else
    # Unknown.
    echo "Unknown OS detected. Please install manually."
    exit 1
fi