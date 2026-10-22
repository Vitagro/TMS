# Utilisation des tarifs et règlements en MAD

Application : https://tms-one-nu.vercel.app

1. **Clients** : créer une fiche avec coordonnées, identifiants d’entreprise et tarif de vente de référence.
2. **Loueurs** : renseigner le tarif d’achat de référence et les conditions de règlement du fournisseur.
3. **Trajets** : sélectionner les deux partenaires, adapter le prix unitaire et la quantité convenus. Les bases de vente et d’achat peuvent être différentes.
4. **Facturation** : sélectionner le trajet pour reprendre le client, la recette et les conditions de règlement ; compléter la prestation, l’émetteur et le taux de TVA. Ouvrir « Détail / PDF » pour imprimer ou enregistrer en PDF.

| Base | Quantité à saisir | Calcul |
|---|---|---|
| Trajet | Nombre de trajets facturés | Prix par trajet × quantité |
| Kilomètre | Kilomètres facturés | Prix par km × quantité |
| Jour | Nombre de jours convenus | Prix par jour × quantité |
| Semaine | Nombre de semaines convenues | Prix par semaine × quantité |
| Mois | Nombre de mois convenus | Prix par mois × quantité |

Les fractions sont acceptées avec deux décimales. La durée n’est pas déduite automatiquement des dates : aucune convention de mois de 30 jours ou d’arrondi à la semaine n’est imposée.

**Exemple** : client à 12,50 MAD/km sur 100 km = 1 250,00 MAD HT ; loueur à 400,00 MAD/jour sur 2 jours = 800,00 MAD HT. Marge avant carburant et autres frais = 450,00 MAD. Les tarifs et quantités sont conservés dans le trajet et ne changent pas si la fiche partenaire est modifiée ensuite.

**Règlement** : virement, chèque, espèces ou autre, délai en jours et conditions libres. Ces champs documentent les conditions ; l’application ne déclenche pas de transfert bancaire.

**Location couvrant plusieurs missions** : répartir le coût ou la durée entre les trajets concernés ; ne pas saisir le coût complet du même mois sur chaque mission. Le loyer mensuel du véhicule est une référence séparée et ne s’ajoute pas automatiquement.

Tous les montants sont en MAD à deux décimales. Le total HT, la TVA et le TTC sont affichés sur les factures et exportés. L’entreprise, ses identifiants, ses coordonnées bancaires et le taux applicable sont à compléter avec vos informations réelles. Aucune conformité réglementaire ni facturation électronique n’est certifiée par cette version.

Vérifications : TypeScript, calculs au centime et rendu des composants ; tests PostgreSQL des cinq bases, du calcul automatique, des tarifs historiques, des quantités positives et de l’isolation entre comptes. Les données de test sont annulées après vérification.
