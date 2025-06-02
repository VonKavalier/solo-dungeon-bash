# solo-dungeon-bash

Un générateur de donjon infini en solo pour rôlistes solitaires.
Chaque matin, recevez une nouvelle scène d’exploration, directement sur votre terminal ou via une notification grâce à [`ntfy`](https://ntfy.sh).

---

## 🌀 Fonctionnalités

- Génère événement dans un donjon mystérieux et infini
- Trois types de journées : **exploration**, **transition**, **contemplation**
- Éléments narratifs variés : salles, ambiances, objets, mystères, etc.
- Notifications automatiques via `ntfy`
- Empêche les journées répétées du même type
- Éditable facilement grâce à des fichiers de données externes (`.txt`)

---

## 🛠️ Installation

### 1. Cloner le dépôt

```bash
git clone https://github.com/ton-utilisateur/solo-dungeon-bash.git
cd solo-dungeon-bash
```

### 2. Rendre le script exécutable

```bash
chmod +x solo-dungeon-bash.sh
```

### 3. Renseigner les variables d'environnement

```bash
NTFY_TOPIC="insert_topic_name_here"
NTFY_SERVER="https://ntfy.sh"
NTFY_TOKEN="insert_token_here"
SAVE_FILE="$HOME/.dungeon_progress"
LAST_TYPE_FILE="$HOME/.dungeon_last_type"
DATA_DIR="./data"
```
---

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

---

## 🧭 Exemple d'exploration

```
🧭 JOURNÉE D'EXPLORATION 🧭

📍 SALLE: Une galerie de portraits glacé·e par un froid pénétrant

🎯 DÉFI: Vous découvrez des statues qui bougent quand on ne les regarde pas
Vous remarquez également des masques expressifs

🔍 INDICE D’AUTRES AVENTURIERS: Vous remarquez des marques de griffes sur les murs
🎲 TAUX DE RÉUSSITE: 60%

💭 CONSIGNES:
- Comment abordez-vous cette situation ?
- Réussissez ou échouez selon le taux indiqué
- Décrivez votre approche et ses conséquences
- Que vous inspire cet élément narratif ?

⏱️ Temps d'écriture: 5-10 minutes
📝 Bonne exploration, aventurier !
```

---

## 🧠 Licence

Ce projet est libre sous licence MIT.
Faites-en ce que vous voulez, améliorez-le, partagez-le — explorez librement !

---

## 💬 Remerciements

Inspiré par la pratique du solo RPG, les générateurs aléatoires, et l’amour des donjons profonds.
