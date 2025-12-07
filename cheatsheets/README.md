# Personal Command-Line Cheatsheets

This directory contains custom cheatsheets for the `cheat` command-line tool.

## Setup

The `cheat` tool is automatically installed and configured by running the `setup-ubuntu.sh` script in the parent directory. It will:

1. Install `cheat` via snap
2. Configure `cheat` to use this directory for personal cheatsheets
3. Link community cheatsheets if available

## Usage

```bash
# List all available cheatsheets
cheat -l

# View a cheatsheet
cheat python

# Search for a command
cheat -s "for loop"

# Edit a cheatsheet
cheat -e python

# Create a new cheatsheet
cheat -e mynewsheet
```

## Available Cheatsheets

- **python**: Python syntax reference (for loops, if statements, while loops, classes)

## Adding New Cheatsheets

Simply create a new file in this directory with your cheatsheet content. The filename will be the command you use with `cheat`.

Example:
```bash
# Create ~/Github/ubuntu-setup-private/cheatsheets/docker
# Then use: cheat docker
```

## Cheatsheet Format

Cheatsheets are plain text files with comments and commands:

```bash
# Section title
# Description of what this does

# Show all containers
docker ps -a

# Remove all stopped containers
docker container prune
```

## More Information

- [cheat GitHub repository](https://github.com/cheat/cheat)
- [Community cheatsheets](https://github.com/cheat/cheatsheets)
