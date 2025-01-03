#!/bin/zsh

# Variables
EXECUTABLE_NAME="cz"
GLOBAL_PATH="/usr/local/bin/$EXECUTABLE_NAME"
COMPLETION_FILE="$HOME/.zsh/completions/_cz"
ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"
BASH_COMPLETION_FILE="$HOME/.bash_completion"

# Supprime le lien symbolique
if [ -L "$GLOBAL_PATH" ]; then
    echo "Suppression du lien symbolique '$GLOBAL_PATH'..."
    sudo rm "$GLOBAL_PATH" > /dev/null 2>&1
fi

# Supprime le fichier d'autocomplétion pour Zsh
if [ -f "$COMPLETION_FILE" ]; then
    echo "Suppression du fichier d'autocomplétion pour Zsh..."
    rm "$COMPLETION_FILE" > /dev/null 2>&1
fi

# Nettoie le fichier .zshrc (retirer les lignes liées à l'autocomplétion)
echo "Nettoyage du fichier .zshrc..."
sed -i '' '/fpath=(~\/.zsh\/completions \$fpath)/d' "$ZSHRC"
sed -i '' '/autoload -Uz compinit/d' "$ZSHRC"
sed -i '' '/compinit/d' "$ZSHRC" > /dev/null 2>&1

# Nettoie le fichier .bashrc pour Bash (si nécessaire)
if [ -f "$BASHRC" ]; then
    echo "Nettoyage du fichier .bashrc..."
    sed -i '' '/source ~\/.bash_completion/d' "$BASHRC" > /dev/null 2>&1
fi

# Vérifie si tout est bien nettoyé
if [ ! -L "$GLOBAL_PATH" ] && [ ! -f "$COMPLETION_FILE" ] && [ ! -d "$HOME/.zsh/completions" ]; then
    echo "Le nettoyage a été effectué avec succès."
else
    echo "Un problème est survenu lors du nettoyage."
fi

exit 0
