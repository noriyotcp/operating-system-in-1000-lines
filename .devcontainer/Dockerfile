FROM mcr.microsoft.com/devcontainers/base:jammy

# install development tools
RUN sudo apt update \
  && sudo apt install -y \
  clang \
  llvm \
  lld \
  qemu-system-riscv32 \
  curl \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists
