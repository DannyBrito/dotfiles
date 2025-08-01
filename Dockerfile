# Test container for dotfiles setup
FROM ubuntu:24.04

# Install basic tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bat \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create a test user
RUN useradd -m -s /bin/bash tempuser

# Switch to test user
USER tempuser
WORKDIR /home/tempuser

# Copy dotfiles to container
COPY --chown=tempuser:tempuser . /home/tempuser/dotfiles

# Set working directory to dotfiles
WORKDIR /home/tempuser/dotfiles
RUN ./bootstrap.sh
ENV SKIP_BCAT=1
RUN ./install-tools.sh
# Start a login shell to automatically source profile
CMD ["/bin/bash", "-l"]