# CLAUDE.md — G1BILLET

Service de génération de billets G1 imprimables avec QR codes.
Crée des portefeuilles Ğ1 (June libre) sous forme de billets physiques ou ZenCards.
Author: Fred (support@qo-op.com). License: AGPL-3.0. Version: 1.0.

## Concept

G1BILLET génère des portefeuilles Ğ1 vides (à financer soi-même) sous forme de billets
imprimables avec QR codes. Plusieurs styles disponibles dont le mode sécurisé ZenCard
(intégré avec Astroport.ONE).

## Structure

```
G1BILLET/
├── G1BILLETS.sh          ← Script principal (génération des billets)
├── MAKE_G1BILLET.sh      ← Script de création batch
├── index.php             ← Interface web (port 33101)
├── install.sh            ← Installation dépendances
├── setup_systemd.sh      ← Service systemd
├── diceware.sh           ← Génération mots de passe (diceware)
├── diceware-wordlist.txt ← Liste de mots diceware
├── key_create_dunikey.py ← Génération clés Duniter (python)
├── keygen/               ← Outils de génération de clés
├── images/               ← Styles de billets (par défaut)
│   ├── _/                ← Style minimal
│   ├── ticket/           ← Style billet classique
│   └── ZenCard/          ← Style ZenCard sécurisé
├── _images/              ← Styles personnalisés (override images/ si présent)
├── styles/               ← CSS pour interface web
├── search/               ← Outils de recherche
├── ♥Box/                 ← Assets spéciaux
├── DICE                  ← Fichier de config (nombre de mots diceware, 1-10)
└── tmp/                  ← Fichiers temporaires générés
```

## Utilisation

### Interface web (port 33101)

```
http://localhost:33101/?montant=10&style=ticket
```

Paramètres URL :
- `montant` — Montant en Ğ1 (affiché sur le billet, `___` si vide)
- `style` — Style du billet (`_`, `ticket`, `ZenCard`, ou email pour mode ZENCARD+@)
- `dice` — Nombre de mots diceware pour le secret (1-10, défaut: 4)

### Ligne de commande

```bash
./G1BILLETS.sh [MONTANT] [STYLE] [DICE] [SECRET1] [SECRET2]

# Exemples
./G1BILLETS.sh 5 ticket 2        # Billet 5 Ğ1, style ticket, 2 mots secret
./G1BILLETS.sh 10 ZenCard        # ZenCard 10 Ğ1
./G1BILLETS.sh 0 user@example.com  # ZENCARD+@ (mode email = lié au MULTIPASS)
```

### Mode ZENCARD+@ (email comme style)

Si `STYLE` est une adresse email valide, G1BILLET génère une ZenCard liée au MULTIPASS
de cet email via Astroport.ONE. DICE forcé à 5 mots.

## Styles de billets

| Style | Description | Sécurité |
|-------|-------------|----------|
| `_` | Minimal (QR codes seulement) | Basique |
| `ticket` | Billet classique avec design | Standard |
| `ZenCard` | Carte intégrée écosystème UPlanet | Renforcée (Astroport) |
| `email@domain` | ZenCard liée au MULTIPASS | Maximum |

Les styles personnalisés dans `_images/$style/` remplacent ceux de `images/$style/`.

## Génération de mots de passe (diceware)

```bash
./diceware.sh [NOMBRE_MOTS]   # Génère N mots aléatoires depuis diceware-wordlist.txt
```

- Fichier `DICE` : configure le nombre de mots par défaut
- Plage valide : 1-10 mots
- Sécurité recommandée : 4-6 mots (compromis mémorabilité/sécurité)

## Installation

```bash
./install.sh          # Installe les dépendances système (qrencode, imagemagick, etc.)
./setup_systemd.sh    # Configure le service systemd g1billet
```

### Déploiement recommandé

```bash
mkdir -p ~/.zen && cd ~/.zen
git clone https://git.p2p.legal/qo-op/G1BILLET.git
cd G1BILLET
./install.sh && ./setup_systemd.sh
```

## Dépendances

- `qrencode` — Génération de QR codes
- `imagemagick` / `convert` — Composition des images de billets
- `php` — Interface web (index.php)
- `key_create_dunikey.py` — Python 3 pour génération clés Duniter
- Astroport.ONE (pour mode ZenCard+@)

## Cryptographie

- Clés générées via `key_create_dunikey.py` (format Duniter / Ğ1)
- Protobuf crypto (`crypto.proto`, `crypto_pb2.py`) pour sérialisation sécurisée
- Sécurité du secret par nombre de mots diceware (4 mots ≈ 51 bits d'entropie)

## Notes

- Les billets générés sont des portefeuilles **vides** — l'utilisateur doit les financer
- Port daemon interne : 33102 (arrêté automatiquement avant nouveau lancement)
- `G1BILLETS.mp4` : vidéo de démonstration du service
