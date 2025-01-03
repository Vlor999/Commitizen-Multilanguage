#!/bin/bash

# Variables
VENV_PATH=$(poetry env info --path 2>/dev/null)
EXECUTABLE_NAME="cz"
GLOBAL_PATH="/usr/local/bin/$EXECUTABLE_NAME"

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

# Vérifie si le lien symbolique fonctionne
if command -v "$EXECUTABLE_NAME" &> /dev/null; then
    echo "'$EXECUTABLE_NAME' est maintenant disponible globalement."
else
    echo "Une erreur s'est produite lors de l'installation. Vérifiez les permissions et réessayez."
    exit 1
fi

exit 0
