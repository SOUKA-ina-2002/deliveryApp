# deliveryApp

----Contexte----

Un livreur souhaite disposer d’une application mobile pour :

• Gérer les points de vente qu’il visite.

• Planifier ses tournées (itinéraires).

• Enregistrer les données des visites et des ventes.

• Suivre les trajets entre sa position GPS et les points de vente.

----Objectifs----

Créer une application Flutter qui permet au livreur de :

1. Gérer ses points de vente (ajout, modification, suppression).
2. Planifier sa tournée.
3. Enregistrer les ventes et les remarques après chaque visite.


----Fonctionnalités attendues----

1. Authentification
   • Une page d'authentification pour sécuriser l'accès à l'application.
2. Gestion des points de vente
   Le livreur peut gérer ses points de vente :
   • Ajouter un point de vente avec :
   o Nom du point de vente.
   o Adresse.
   o Contact (nom et numéro de téléphone).
   o Capacité de stockage.
   o Coordonnées GPS.
   • Modifier ou supprimer un point de vente.
3. Planification de la tournée
   • Le livreur peut sélectionner les points de vente qu’il prévoit de visiter pour une
   journée donnée.
   • L’ordre des visites peut être organisé par le livreur.
4. Géolocalisation et itinéraire
   • Afficher tous les points de vente sur une carte interactive.
   • Montrer l'itinéraire entre la position GPS actuelle du livreur et les points de vente
   sélectionnés dans la tournée.
   • L’itinéraire doit être téléchargé via API de openrouteservice et enregistré dans la base
   de données pour le visualiser en mode offline.
5. Suivi des ventes
   • Après chaque visite, le livreur enregistre les données suivantes :
   o Quantité vendue.
   o Observations ou remarques.
   o Heure de la visite.

----Technologies utilisés----

• Flutter : Développement de l’application.

• SQLite : Stockage local des données.

• Leaflet.js : Carte interactive pour la géolocalisation et la navigation.
