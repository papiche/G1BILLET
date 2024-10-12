# G1BILLET

## Présentation
Ce code est un générateur de G1BILLETS qui utilise duniter.py keygen imagemagik amzqr

Il lance la fabrication de "G1 Portefeuilles" vides à remplir soi-même !
Les G1Billets sont assemblés dans un fichier PDF pour les imprimer facilement sur une imprimante A4 et vous en servir comme chéquier.

Avant de vous en servir, utilisez Cesium pour flasher le QR Code et effectuer le virement correspondant à son montant sur chaque portefeuille.
Ensuite, offrez ces G1Billets à qui vous voulez.


Chaque billet est composé des images ```fond.jpg g1.png logo.png``` (à modifier ou remplacer par les votres) y sont ensuite ajouté différents signes et qrcodes.

En utilisant le style "xbian" vous activez le mode "ZenCard".
Un G1BILLET sécurisé qui fonctionne sur les [♥Box Ğ1Station](https://pad.p2p.legal/s/Astroport.ONE).


Son détenteur peut alors utiliser l'identifiant/mot de passe pour contrôler la clef du portefeuille correspondant.

* [FIL DE DISCUSSION SUR LE FORUM MONNAIE LIBRE](https://forum.monnaie-libre.fr/t/nouveau-g1-billets/14529?u=qoop)
* [VIDEO ZenCard TEASER](https://tube.p2p.legal/w/oBufWkzT3whWk3GabX3GAD)

> :warning: **Pour utiliser ZenCard : Installez [Astroport.ONE](https://git.p2p.legal/STI/Astroport.ONE).**


## Utilisation

En ligne de commande, adaptez ces lignes à votre style ;)

```
montant=0 # Valeur faciale à indiquer sur le billet (0 : indéfini)
style="_" # Style du G1BILLET
secu=7 # Nombre de mots "diceware" (corrélé à la complexité du PASS)
./G1BILLETS.sh "$montant" "$style" "$secu"
```

Personnalisez vos G1Billets, en modifiant les images dans ```images/$style``` (copiez-collez celles d'autres styles pour commencer le votre)

* PLANCHE de 6  :   http://g1billet.localhost:33101
* G1TICKET  de 10  :   http://g1billet.localhost:33101/?montant=10&style=ticket
* ZenCard "avec dedicace" :   http://g1billet.localhost:33101/?montant=0&style=votre@email.com

## Pré-requis Installation

Pour Linux DEBIAN, Ubuntu, recommandé: [Linux Mint](https://www.linuxmint.com/)

```
# Installer git
sudo apt install git
```

# INSTALLATION (**for Linux (systemd) only**)

> :warning: **Vous souhaitez utiliser ZenCard? Installez [Astroport.ONE](https://git.p2p.legal/STI/Astroport.ONE).**

Utiliser le mode G1BILLET (seulement).

```
# Création et clonage du code dans ""~/.zen"
mkdir -p ~/.zen
cd ~/.zen
git clone https://git.p2p.legal/qo-op/G1BILLET.git
cd G1BILLET

# Installation
./install.sh

# Activation systemd
./setup_systemd.sh

## Ajouter raccourci sur votre Bureau
~/.zen/G1BILLET/add_desktop_shortcut.sh

## Ouvrir "Interface Web"
xdg-open http://localhost:33101/


```

---

# CA NE FONCTIONNE PAS ?

Faites ces TESTS.

## Service is running ?
```
sudo systemctl status g1billet

● g1billet.service - G1BILLET API
     Loaded: loaded (/etc/systemd/system/g1billet.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2023-04-20 21:11:39 CEST; 46min ago
   Main PID: 3250895 (G1BILLETS.sh)
      Tasks: 3 (limit: 18381)
     Memory: 9.4M
     CGroup: /system.slice/g1billet.service
             ├─3250895 /bin/bash /home/fred/workspace/G1BILLET/G1BILLETS.sh daemon
             ├─3253436 /bin/bash /home/fred/workspace/G1BILLET/G1BILLETS.sh daemon
             └─3253438 nc -l -p 33101 -q 1
```


## Crypto is working ?
```
./keygen 'toto' 'toto'
EA7Dsw39ShZg4SpURsrgMaMqrweJPUFPYHwZA8e92e3D

```

## Graphics are OK ?
```
## CHANGE VARIABLES TO TEST YOUR STYLE ;)
SALT=toto; PEPPER=toto;
SECRET=toto; MONTANT=___;
BILLETPUBKEY=EA7Dsw39ShZg4SpURsrgMaMqrweJPUFPYHwZA8e92e3D;
UNIQID=toto; STYLE=xastro
ASTRONAUTENS=k51qzi5uqu5dl1zsbaala0bi26zpl5cfi7mogjwl9cg76d8awfc1d0iv738kak
EMAIL=toto@yopmail.com

BILLETNAME=$(echo $SALT | sed 's/ /_/g')

./MAKE_G1BILLET.sh "${SALT}" "${SECRET}" "${MONTANT}" "${BILLETPUBKEY}" "${UNIQID}" "${STYLE}" "${ASTRONAUTENS}" "${EMAIL}"

xdg-open tmp/g1billet/$UNIQID/$BILLETNAME.BILLET.jpg
```

* NB: Si une erreur du type "not autorized" apparait,
éditez /etc/ImageMagick-6/policy.xml pour commenter la ligne qui bloque la création de "PDF"

ou réglez le problème avec ce script :

```
echo "######### CORRECT IMAGEMAGICK PDF ############"
if [[ $(cat /etc/ImageMagick-6/policy.xml | grep PDF) ]]; then
    cat /etc/ImageMagick-6/policy.xml | grep -Ev PDF > /tmp/policy.xml
    sudo cp /tmp/policy.xml /etc/ImageMagick-6/policy.xml
fi
```

## LOG monitoring

```
tail -f ~/.zen/G1BILLET/tmp/G1BILLETS.log
```

---

# PERSONNALISATION GRAPHIQUE

Pour changer le fond, le logo et le sigle de votre G1BILLET

Créez un répertoire dont le nom commence par "_"
et recopiez les modèles par défaut

```
mkdir -p ~/.zen/G1BILLET/_images
cp -R ~/.zen/G1BILLET/images/* ~/.zen/G1BILLET/_images

# Redémarrer G1BILLET
sudo systemctl restart g1billet

```

![](https://ipfs.copylaradio.com/ipfs/QmbLcxZR8C84PiSsFDbunSDj7nVfFC6TE2B8SjYnhp6Xuo)

Utilisez GIMP pour modifier les images...

# Support : [dites nous ce qui ne fonctionne pas](/qo-op/G1BILLET/issues)
[et ce qui fonctionne](https://pad.p2p.legal/s/G1BILLET)

En opérant le service G1BILLET, vous devenez "tiers de confiance".
Vous définissez l'usage selon votre envie

> La planche que vous allez imprimer est un chéquier multifonction.

Pour lui assurer une convertibilité en Ğ1, vous devrez [les créditer en flashant leur QRCode avec Cesium](https://forum.monnaie-libre.fr/t/nouveau-g1-billets/14529/4?u=qoop).

Une planche contient 6 G1BILLETS qui comportent des codes d'accès à "une clef de chiffrement" donnant accès à [notre crypto zone](https://www.copylaradio.com/blog/blog-1/post/espace-et-planetes-numeriques-33). Ces billets indiquent l'emplacement, la clef publique, et la clef, privée (ou non), d'un coffre numérique s'y trouvant.

G1BILLET révolutionne le "BILLET" tel que nous le connaissons...

## Un "bon au porteur" de nouvelle génération

**1. Effacer le secret**

    * Définitivement_

    Dans le cas où plus personne ne connaît le secret, et ce qui est relié à ce G1BILLET est immuable (impossible à vider).

Sa valeur en G1 pourra augmenter mais celle du morceau de papier dépendra du contrôle du nombre de ses copies,
C'est la version qui se rapproche le plus de ce que nous connaissons comme "Billet de Banque".
Celui-ci devrait donc être détruit lorsque son émetteur le "récupère" en assurant la convertibilité promise.

Associé à des données multimédia, vous disposez d'un "Bon pour y accéder" que vous pouvez offrir.
Selon la nature de ces données, devenues immuables et associables à des défis, ils sont utilisables pour "monétiser l'accès aux données".

    * Temporairement_

   En cachant le secret sous une couche "case à gratter" par exemple, le G1BILLET peut passer de son statut "Billet de Banque" à celui de Cadeau à accepter.
Son contenu en G1 est alors récupérable par celui qui révèle le secret. A ce moment, l’œuvre et le portefeuille associée au G1BILLET appartiennent pleinement à son propriétaire.

> Garder une copie du secret ou pas.
> C'est ce qui conditionne le premier maillon de confiance.

**1. Laisser le secret**

Dans ce cas, le "bien numérique" rattaché à ce secret est sous le contrôle de celui qui utilise ce codes, donc le possède, ou en aura fait une copie.
Cela concerne une ressource commune et abondante pour un groupe à bon niveau de confiance relatif

Par exemple, on pourra s'en servir comme Kit découverte "Gchange/Cesium" à offrir à ses amis (avec de la monnaie dessus ou pas).


**Essayez!! Envoyez-nous vos expériences...**

---

Réalisé et offert dans l'espoir que la(/les) monnaie(s) libre(s) deviennent réalité pour tous.

> Le saviez-vous ? Vous pouvez ouvrir un compte sur [GCHANGE](https://gchange.fr) avec les identifiants de votre G1BILLET/ZenCard.
Il s'agit également d'un portefeuille [Cesium](https://cesium.app).

> :warning: ATTENTION. N'utilisez pas ce compte pour devenir membre forgeron !
Ou bien créez un ZenCard de haute sécurité que vous n'utiliserez que sur Cesium dans ce cas précis.

Merci pour vos encouragements et vos dons en JUNE

* [Fred](https://demo.cesium.app/#/app/wot/DsEx1pS33vzYZg4MroyBV9hCw98j1gtHEhwiZ5tK7ech/Fred)


Des questions? Contactez [support@qo-op.com](mailto:support@qo-op.com)

---

# [OpenCollective](https://opencollective.com/monnaie-libre)

## On compte sur vous.

