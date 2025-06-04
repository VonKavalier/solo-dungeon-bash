#!/bin/bash

# === Chargement de la configuration ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Erreur: Le fichier de configuration '$CONFIG_FILE' n'existe pas."
  echo "Copiez 'config.example.sh' vers 'config.sh' et remplissez vos informations."
  exit 1
fi

source "$CONFIG_FILE"

# === Initialisation ===
initialize_day_counter() {
  if [ ! -f "$SAVE_FILE" ]; then
    echo "1" > "$SAVE_FILE"
  fi
  DAY=$(cat "$SAVE_FILE")
  SEED=$(date +%Y%m%d)
  RANDOM=$SEED
}

# === Données ===
load_array() {
  local filename=$1
  local varname=$2
  mapfile -t $varname < $filename
}

load_arrays() {
  # Vérifier que le dossier data existe
  if [ ! -d "$DATA_DIR" ]; then
    echo "Erreur: Le dossier de données '$DATA_DIR' n'existe pas."
    exit 1
  fi

  load_array $DATA_DIR/rooms.txt ROOMS
  load_array $DATA_DIR/atmospheres.txt ATMOSPHERES
  load_array $DATA_DIR/threats.txt THREATS
  load_array $DATA_DIR/objects.txt OBJECTS
  load_array $DATA_DIR/traces.txt TRACES
  load_array $DATA_DIR/mysteries.txt MYSTERIES
  load_array $DATA_DIR/rest_activities.txt REST_ACTIVITIES
  load_array $DATA_DIR/reflection_prompts.txt REFLECTION_PROMPTS
  load_array $DATA_DIR/transition_moments.txt TRANSITION_MOMENTS
  load_array $DATA_DIR/transition_ambiances.txt TRANSITION_AMBIANCES
  load_array $DATA_DIR/transition_prompts.txt TRANSITION_PROMPTS
}

# === Types de journées ===
update_type_history() {
  local new_type=$1
  local last_type=""
  local consecutive_count=1

  if [ -f "$LAST_TYPE_FILE" ]; then
    last_type=$(head -n1 "$LAST_TYPE_FILE")
    consecutive_count=$(tail -n1 "$LAST_TYPE_FILE" 2>/dev/null || echo "1")
  fi

  # Si même type que précédent, incrémenter le compteur
  if [ "$new_type" = "$last_type" ]; then
    consecutive_count=$((consecutive_count + 1))
  else
    consecutive_count=1
  fi

  # Sauvegarder le nouveau type et le compteur
  echo "$new_type" > "$LAST_TYPE_FILE"
  echo "$consecutive_count" >> "$LAST_TYPE_FILE"
}

# === Types de journées avec système narratif ===
determine_day_type() {
  CONTEMPLATIVE_DAY=false
  TRANSITION_DAY=false
  EXPLORATION_DAY=false

  local last_type=""
  local consecutive_count=1

  # Lire l'historique des derniers types
  if [ -f "$LAST_TYPE_FILE" ]; then
    last_type=$(head -n1 "$LAST_TYPE_FILE")
    consecutive_count=$(tail -n1 "$LAST_TYPE_FILE" 2>/dev/null || echo "1")
  fi

  # Logique narrative

  # Règle 1: Après 3 explorations consécutives → FORCER contemplation
  if [ "$last_type" = "exploration" ] && [ $consecutive_count -ge 3 ]; then
    CONTEMPLATIVE_DAY=true
    update_type_history "contemplative"
    return
  fi

  # Règle 2: Après 2 explorations → favoriser fortement contemplation (70%)
  if [ "$last_type" = "exploration" ] && [ $consecutive_count -eq 2 ]; then
    if [ $((RANDOM % 100)) -lt 70 ]; then
      CONTEMPLATIVE_DAY=true
      update_type_history "contemplative"
      return
    fi
  fi

  # Règle 3: Après contemplation → favoriser transition (60%)
  if [ "$last_type" = "contemplative" ]; then
    if [ $((RANDOM % 100)) -lt 60 ]; then
      TRANSITION_DAY=true
      update_type_history "transition"
      return
    fi
  fi

  # Règle 4: Après transition → favoriser exploration (80%)
  if [ "$last_type" = "transition" ]; then
    if [ $((RANDOM % 100)) -lt 80 ]; then
      EXPLORATION_DAY=true
      update_type_history "exploration"
      return
    fi
  fi

  # Règles par défaut (équilibrées)
  local type=$((RANDOM % 100))
  if [ $type -lt 40 ]; then
    EXPLORATION_DAY=true
    update_type_history "exploration"
  elif [ $type -lt 70 ]; then
    TRANSITION_DAY=true
    update_type_history "transition"
  else
    CONTEMPLATIVE_DAY=true
    update_type_history "contemplative"
  fi
}

# === Génération des journées ===
generate_contemplative_day() {
  local rest="${REST_ACTIVITIES[$RANDOM % ${#REST_ACTIVITIES[@]}]}"
  local prompt="${REFLECTION_PROMPTS[$RANDOM % ${#REFLECTION_PROMPTS[@]}]}"
  MESSAGE="🕯️ JOURNÉE CONTEMPLATIVE 🕯️

$rest

💭 RÉFLEXION DU JOUR:
$prompt

📝 CONSIGNES:
- Prenez le temps de développer vos pensées
- Explorez l'état d'esprit de votre personnage
- Réfléchissez à ce que vous avez vécu
- Écrivez sur vos motivations, vos peurs, vos espoirs
- Faites le lien entre vos expériences passées

⏱️ Temps d'écriture: 5-10 minutes
🧘 Prenez ce moment de répit, aventurier."
}

generate_transition_day() {
  local moment="${TRANSITION_MOMENTS[$RANDOM % ${#TRANSITION_MOMENTS[@]}]}"
  local ambiance="${TRANSITION_AMBIANCES[$RANDOM % ${#TRANSITION_AMBIANCES[@]}]}"
  local prompt="${TRANSITION_PROMPTS[$RANDOM % ${#TRANSITION_PROMPTS[@]}]}"
  MESSAGE="🚶 JOUR DE TRANSITION 🚶

$moment

$ambiance, $prompt

📝 CONSIGNES SIMPLES:
- Laissez-vous porter par l'ambiance du moment
- Décrivez ce que vous ressentez, voyez, entendez
- Explorez vos pensées pendant ce déplacement

⏱️ Temps d'écriture: 3-8 minutes
🗺️ Poursuivez votre chemin, aventurier."
}

generate_exploration_day() {
  local room="${ROOMS[$RANDOM % ${#ROOMS[@]}]}"
  local atmosphere="${ATMOSPHERES[$RANDOM % ${#ATMOSPHERES[@]}]}"
  local threat="${THREATS[$RANDOM % ${#THREATS[@]}]}"
  local object="${OBJECTS[$RANDOM % ${#OBJECTS[@]}]}"

  local narrative=""
  if [ $((RANDOM % 100)) -lt 50 ]; then
    if [ $((RANDOM % 2)) -eq 0 ]; then
      local trace="${TRACES[$RANDOM % ${#TRACES[@]}]}"
      narrative="🔍 INDICE D’AUTRES AVENTURIERS: Vous remarquez $trace"
    else
      local mystery="${MYSTERIES[$RANDOM % ${#MYSTERIES[@]}]}"
      narrative="❓ MYSTÈRE: Vous découvrez $mystery"
    fi
  fi

  local success=$((30 + RANDOM % 51))
  MESSAGE="🧭 JOURNÉE D'EXPLORATION 🧭

📍 SALLE: $room $atmosphere

🎯 DÉFI: Vous découvrez $threat
Vous remarquez également $object

$narrative

🎲 TAUX DE RÉUSSITE: $success%

💭 CONSIGNES:
- Comment abordez-vous cette situation ?
- Réussissez ou échouez selon le taux indiqué
- Décrivez votre approche et ses conséquences
- Que vous inspire cet élément narratif ?

⏱️ Temps d'écriture: 5-10 minutes
📝 Bonne exploration, aventurier !"
}

# === Notification ===
send_notification() {
  curl -s \
    -H "Title: 🏰 Solo Dungeon Bash - Jour $DAY" \
    -H "Priority: default" \
    -H "Tags: game,rpg,writing" \
    -H "Authorization: Bearer $NTFY_TOKEN" \
    -d "$MESSAGE" \
    "$NTFY_SERVER/$NTFY_TOPIC"
}

# === Entrée principale ===
main() {
  initialize_day_counter
  load_arrays
  determine_day_type

  if [ "$CONTEMPLATIVE_DAY" = true ]; then
    generate_contemplative_day
  elif [ "$TRANSITION_DAY" = true ]; then
    generate_transition_day
  else
    generate_exploration_day
  fi

  #echo "$MESSAGE"
  send_notification
  echo $((DAY + 1)) > "$SAVE_FILE"
}

main "$@"

