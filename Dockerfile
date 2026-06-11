FROM python:3.7

# Ne pas lancer l'app en root dans Docker
RUN useradd flask

WORKDIR /home/flask

# Ajouter tout le contexte sauf le contenu de .dockerignore
ADD . .

# Installer les dépendances Python (pas besoin de venv car Docker)
RUN pip install -r requirements.txt

# Donner les permissions et changer le propriétaire
RUN chmod a+x app.py test.py && \
    chown -R flask:flask ./

# Déclarer la configuration de l'app
ENV FLASK_APP app.py

EXPOSE 5000

# Changer d'utilisateur pour lancer l'app
USER flask

CMD ["./app.py"]
