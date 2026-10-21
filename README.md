# Transport Pilot

Première version TMS en français : Next.js, TypeScript et Supabase. Hébergement cible Vercel.

## Démarrage

1. `npm ci`
2. Copier `.env.example` vers `.env.local` et renseigner l’URL Supabase et la clé publique publishable. Ne jamais utiliser une clé service_role dans le navigateur.
3. Appliquer `supabase/migrations/202610210001_initial.sql` à un nouveau projet Supabase.
4. Activer l’authentification e-mail/mot de passe et la confirmation e-mail dans Supabase. Configurer Site URL avec le domaine Vercel. Configurer SMTP avant utilisation en production.
5. `npm run dev`, puis créer un compte et confirmer l’adresse e-mail.

## Déploiement

Créer un dépôt GitHub privé et y pousser ce dossier (sans `.env.local`). Importer le dépôt dans Vercel, choisir Next.js et ajouter les deux variables de `.env.example` en production et prévisualisation. Lancer le déploiement. Aucun secret administrateur n’est requis au runtime.

## Périmètre

- Dashboard et rentabilité : recettes, coûts et marge contributive ; flotte et derniers trajets.
- Trajets, carburant, véhicules, loueurs, chauffeurs et facturation : création, modification, suppression, recherche et export CSV.
- Authentification Supabase côté navigateur ; toute lecture/écriture protégée par RLS PostgreSQL. Isolation par utilisateur, sans partage d’équipe dans cette version.
- Clés étrangères composites empêchant les liens entre comptes ; montants non négatifs, références et factures uniques par compte.

La marge contributive exclut les loyers mensuels et charges fixes : ce n’est pas un résultat net comptable. Les factures constituent un registre de suivi ; l’impression disponible est celle du tableau et ne constitue pas une facture réglementaire. Pas encore de PDF de facture, de facturation électronique, de verrouillage comptable ou de numérotation automatique. Devise initiale EUR, montants HT.

## Vérification

`npm run typecheck` et `npm run build`. Avant production, vérifier avec deux comptes distincts que les lectures, modifications et associations croisées sont refusées ; vérifier un cycle complet loueur → véhicule → chauffeur → trajet → carburant → facture. Aucun jeu de données fictif n’est injecté.
