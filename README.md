# solo-dungeon-bash

Un générateur de donjon infini en solo pour rôlistes solitaires.
Chaque matin, recevez une nouvelle scène d’exploration via une notification grâce à [`ntfy`](https://ntfy.sh).

## 🌀 Fonctionnalités

- Génère un événement par jour dans un donjon mystérieux et infini
- Quatre types de journées : **exploration**, **transition**, **contemplation**, **rencontre**
- Éléments narratifs variés : salles, ambiances, objets, mystères, personnages, etc.
- Notifications automatiques via `ntfy`
- Éditable facilement grâce à des fichiers de données externes (`.txt`)

## 🛠️ Installation

### 1. Cloner le dépôt

```bash
git clone https://github.com/VonKavalier/solo-dungeon-bash.git
cd solo-dungeon-bash
```

### 2. Rendre le script exécutable

```bash
chmod +x solo-dungeon-bash.sh
```

### 3. Renseigner les variables d'environnement

```bash
# 1. Copier le fichier d'exemple
cp config.example.sh config.sh

# 2. Éditer avec vos vraies valeurs
nano config.sh
```

## 🧑‍💻 Utilisation

```bash
 # Envoie une notification avec l'événement généré pour la date du jour
./solo-dungeon-bash.sh

# Affiche l'événement de la date (seed) précisée en paramètre, en lecture seule. Ici le 10/07/2025
./solo-dungeon-bash.sh --seed 20250710
```

## ⏰ Automatiser avec cron

Recevez une notification chaque jour à 7h du matin :

```bash
crontab -e
```

Ajoutez cette ligne :

```bash
0 7 * * * /chemin/vers/solo-dungeon-bash.sh
```

🔔 Vous recevrez une notification avec l’événement du jour !

## 🧭 Exemple d'exploration

```
🧭 JOURNÉE D'EXPLORATION 🧭

📍 SALLE: Un théâtre de marionnettes marqué·e par des traces de gel

🎯 DÉFI: Vous découvrez des portraits aux yeux qui suivent
Vous remarquez également des pinceaux aux poils dorés

❓ MYSTÈRE: Vous découvrez des cercueils vides aux couvercles brisés
🎲 TAUX DE RÉUSSITE: 37%

💭 CONSIGNES:
- Comment abordez-vous cette situation ?
- Réussissez ou échouez selon le taux indiqué
- Décrivez votre approche et ses conséquences
- Que vous inspire cet élément narratif ?

⏱️ Temps d'écriture: 5-10 minutes
📝 Bonne exploration, aventurier !
```

## 🧠 Licence

Ce projet est libre sous licence MIT.
Faites-en ce que vous voulez, améliorez-le, partagez-le — explorez librement !

## 💬 Remerciements

Inspiré par la pratique du solo RPG, les générateurs aléatoires, et l’amour des donjons profonds.
