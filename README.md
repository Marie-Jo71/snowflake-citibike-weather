# snowflake-citibike-weather
Projet d’analyse de données vélo et météo avec Snowflake
 

Ce projet a été réalisé dans le cadre d’un exercice de formation sur Snowflake.  
Il combine l’analyse de données structurées (trajets de vélos Citibike à New York)  
et semi-structurées (conditions météorologiques en JSON),  afin de répondre à la question suivante : Quel est l’impact des conditions météorologiques sur le nombre de trajets à vélo ?

Étapes techniques

1. Création des bases de données

- citibikepour les trajets
- weather pour les données JSON météo

2. Chargement des données

- Fichiers csv via un STAGE externe depuis un bucket S3
- Fichiers json météo depuis un autre STAGE

 3. Analyse

- Moyenne de durée, distance et nombre de trajets par heure
- Répartition par jour de la semaine 
- Analyse croisée entre météo et nombre de trajets

---

Contenu

- citibike_weather_project.sql → script complet du projet (création de tables, formats, analyses, etc.)


Résultat attendu

- Une vue claire sur l’influence de la météo (ensoleillé, pluvieux, etc.) sur le volume de trajets à vélo à New York .


Technologies utilisées

- Snowflake (SQL + VARIANT pour JSON)
- S3 / STAGE
- Fonctions intégrées :HAVERSINE, DATE_TRUNC, CASE, JOIN, TRANSLATE, etc.

---

## Réalisé par

Marie Josiane ODZALI  
Étudiante en MBA Big Data & Intelligence Artificielle  
Avril 2025

