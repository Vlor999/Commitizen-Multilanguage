#!/bin/zsh

# Variables
VENV_PATH=$(poetry env info --path 2>/dev/null)
EXECUTABLE_NAME="cz"
GLOBAL_PATH="/usr/local/bin/$EXECUTABLE_NAME"
COMPLETION_FILE="$HOME/.zsh/completions/_cz"

# Vérifie si Poetry est installé
if ! command -v poetry &> /dev/null; then
    echo "Poetry n'est pas installé. Veuillez l'installer avant de continuer."
    exit 1
fi

# Vérifie si l'environnement virtuel est disponible
if [ -z "$VENV_PATH" ]; then
    echo "Aucun environnement virtuel trouvé pour ce projet."
    echo "Création de l'environnement virtuel avec 'poetry install'..."
    poetry install
    VENV_PATH=$(poetry env info --path 2>/dev/null)
    
    # Vérifie si l'installation a réussi
    if [ -z "$VENV_PATH" ]; then
        echo "Échec de la création de l'environnement virtuel. Veuillez vérifier les erreurs et réessayer."
        exit 1
    fi
fi

# Vérifie si le fichier cz existe dans le virtualenv
if [ ! -f "$VENV_PATH/bin/$EXECUTABLE_NAME" ]; then
    echo "L'exécutable '$EXECUTABLE_NAME' n'existe pas dans l'environnement virtuel. Assurez-vous que Commitizen est installé."
    exit 1
fi

# Supprime l'ancien lien symbolique s'il existe
if [ -L "$GLOBAL_PATH" ]; then
    echo "Suppression de l'ancien lien symbolique..."
    sudo rm "$GLOBAL_PATH"
fi

# Crée un nouveau lien symbolique
echo "Création du lien symbolique global pour '$EXECUTABLE_NAME'..."
sudo ln -s "$VENV_PATH/bin/$EXECUTABLE_NAME" "$GLOBAL_PATH"

# Crée le fichier d'autocomplétion pour cz
echo "Création du fichier d'autocomplétion pour '$EXECUTABLE_NAME'..."

mkdir -p "$HOME/.zsh/completions"

cat <<'EOF' > "$COMPLETION_FILE"
# Fichier d'auto-complétion pour cz (Commitizen)

_cz() {
    local commands
    commands=(
        "init: Initialiser un nouveau projet"
        "bump: Mettre à jour la version"
        "changelog: Générer un changelog"
        "check: Vérifier la conformité des messages de commit"
        "version: Afficher la version de Commitizen"
        "help: Afficher l'aide"
    )
    _describe 'commande' commands
}

compdef _cz cz
EOF

# Assure-toi que Zsh peut charger les complétions
echo "Ajout du répertoire des complétions à Zsh..."

if ! grep -q "fpath=(~/.zsh/completions \$fpath)" "$HOME/.zshrc"; then
    echo 'fpath=(~/.zsh/completions $fpath)' >> "$HOME/.zshrc"
fi

if ! grep -q "autoload -Uz compinit" "$HOME/.zshrc"; then
    echo 'autoload -Uz compinit' >> "$HOME/.zshrc"
    echo 'compinit' >> "$HOME/.zshrc"
fi

# Recharge le fichier .zshrc pour prendre en compte les modifications
echo "Recharge du fichier .zshrc..."
source "$HOME/.zshrc"

# Vérifie si le lien symbolique fonctionne
if command -v "$EXECUTABLE_NAME" &> /dev/null; then
    echo "'$EXECUTABLE_NAME' est maintenant disponible globalement."
else
    echo "Une erreur s'est produite lors de l'installation. Vérifiez les permissions et réessayez."
    exit 1
fi

exit 0
