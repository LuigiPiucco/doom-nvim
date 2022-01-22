FROM	 pandoc/core:latest-ubuntu

# Update repositories
RUN apt-get update

# Add neovim PPA
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:neovim-ppa/unstable

# Install neovim and runtime dependencies
RUN apt-get install -y neovim ripgrep nodejs npm git bash gcc jq wget unzip

ENTRYPOINT ["bash"]
