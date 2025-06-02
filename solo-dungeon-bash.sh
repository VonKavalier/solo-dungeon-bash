#!/bin/bash

# === Configuration ===
NTFY_TOPIC="insert_topic_name_here"
NTFY_SERVER="https://ntfy.sh"
NTFY_TOKEN="insert_token_here"
SAVE_FILE="$HOME/.dungeon_progress"
LAST_TYPE_FILE="$HOME/.dungeon_last_type"
DATA_DIR="./data"

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
determine_day_type() {
  CONTEMPLATIVE_DAY=false
  TRANSITION_DAY=false
  EXPLORATION_DAY=false

  local last_type=""
  if [ -f "$LAST_TYPE_FILE" ]; then
    last_type=$(cat "$LAST_TYPE_FILE")
  fi

  for attempt in {1..10}; do
    local type=$((RANDOM % 100))
    if [ $type -lt 25 ] && [ "$last_type" != "contemplative" ]; then
      CONTEMPLATIVE_DAY=true
      echo "contemplative" > "$LAST_TYPE_FILE"
      return
    elif [ $type -lt 45 ] && [ "$last_type" != "transition" ]; then
      TRANSITION_DAY=true
      echo "transition" > "$LAST_TYPE_FILE"
      return
    else
      EXPLORATION_DAY=true
      echo "exploration" > "$LAST_TYPE_FILE"
      return
    fi
  done

  # fallback
  EXPLORATION_DAY=true
  echo "exploration" > "$LAST_TYPE_FILE"
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
🏰 Poursuivez votre chemin, aventurier."
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
    -H "Title: 🏰 Nouvelle Salle - Jour $DAY" \
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

