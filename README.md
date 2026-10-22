# Transport Pilot

Première version TMS en français : Next.js, TypeScript et Supabase. Hébergement cible Vercel.

## Démarrage

1. `npm ci`
2. Copier `.env.example` vers `.env.local` et renseigner l’URL Supabase et la clé publique publishable. Ne jamais utiliser une clé service_role dans le navigateur.
3. Appliquer les fichiers SQL de `supabase/migrations/` dans l’ordre de leur nom à un nouveau projet Supabase.
4. Activer l’authentification e-mail/mot de passe et la confirmation e-mail dans Supabase. Configurer Site URL avec le domaine Vercel. Configurer SMTP avant utilisation en production.
5. `npm run dev`, puis créer un compte et confirmer l’adresse e-mail.

## Déploiement

Le dépôt GitHub `Vitagro/TMS` est public conformément au choix du propriétaire ; les fichiers `.env.local` sont exclus. Le projet Vercel `tms` importe sa branche `main`. Les deux variables de `.env.example` sont configurées en production et prévisualisation. Aucun secret administrateur n’est requis au runtime.

## Périmètre

- Dashboard et rentabilité : recettes, coûts et marge contributive ; flotte et derniers trajets.
- Trajets, carburant, véhicules, loueurs, clients, chauffeurs et facturation : création, modification, suppression, recherche et export CSV.
- Authentification Supabase côté navigateur ; toute lecture/écriture protégée par RLS PostgreSQL. Isolation par utilisateur, sans partage d’équipe dans cette version.
- Clés étrangères composites empêchant les liens entre comptes ; montants non négatifs, références et factures uniques par compte.

Tous les montants sont en dirhams marocains (MAD), avec deux décimales, y compris les exports. Aucun montant existant n’a été converti : les tables monétaires étaient vides lors du changement. Appliquer aussi la migration `20261021230928_mad_and_business_details.sql` pour les nouveaux champs et la devise en base.

Les trajets comportent commande/BL, sous-traitant, marchandise, poids, adresses, livraison et instructions. Les véhicules comportent charge utile, assurance et contrôle technique ; les loueurs disposent de leurs coordonnées et identifiants d’entreprise ; les chauffeurs disposent des informations du permis ; le carburant comporte station et justificatif.

La fiche de facturation détaillée permet l’impression ou l’enregistrement en PDF via le navigateur : émetteur, client, adresses, ICE/IF/RC, prestation, dates, règlement, banque/RIB, HT, TVA et TTC. Le taux de TVA est saisi explicitement et n’est pas présumé. Les identifiants, mentions et taux applicables doivent être vérifiés avant émission. Pas encore de facturation électronique, de verrouillage comptable ou de numérotation automatique.

La marge contributive exclut les loyers mensuels et charges fixes : ce n’est pas un résultat net comptable. Aucun module de devis commerciaux n’a été ajouté.

## Tarification et règlement

Créer les fiches Clients et Loueurs avec leur base tarifaire (trajet, kilomètre, jour, semaine ou mois), le prix unitaire HT en MAD, le mode de règlement, le délai en jours et les conditions convenues. Modes disponibles : virement, chèque, espèces et autre. Aucun paiement bancaire n’est exécuté par l’application.

Dans un trajet, sélectionner un client et éventuellement un loueur. Les tarifs des fiches servent de valeurs initiales ; les prix et quantités peuvent être adaptés à la mission. Recette HT = tarif de vente × quantité ; coût loueur HT = tarif d’achat × quantité. Les calculs sont contrôlés en base et les tarifs sont conservés sur le trajet pour préserver l’historique. Modifier ensuite un partenaire ne modifie pas les missions déjà enregistrées.

Les quantités sont explicites : kilomètres facturés, nombre de trajets, jours, semaines ou mois convenus, avec fractions possibles à deux décimales. Pas de conversion automatique d’une durée calendaire en semaines ou mois. Une location couvrant plusieurs missions doit être répartie entre ces missions pour éviter de comptabiliser plusieurs fois le même loyer. Le loyer mensuel du véhicule reste une référence et n’est pas ajouté automatiquement aux coûts par trajet.

Dans Facturation, choisir le trajet pour reprendre le client, le prix de vente et les conditions de règlement. Compléter les données de l’émetteur et le taux de TVA applicable avant émission. L’impression permet l’enregistrement en PDF via le navigateur.

## Vérification

`npm run typecheck` et `npm run build`. Avant production, vérifier avec deux comptes distincts que les lectures, modifications et associations croisées sont refusées ; vérifier un cycle complet loueur → véhicule → chauffeur → trajet → carburant → facture. Aucun jeu de données fictif n’est injecté.
