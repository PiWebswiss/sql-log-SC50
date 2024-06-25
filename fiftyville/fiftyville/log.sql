-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Find description of this crime
SELECT description FROM crime_scene_reports
WHERE month = 7 AND day = 28 
AND street = 'Humphrey Street';

-- Two incidents happened that day. Only one is related to a thief and we have three witnesses.
-- Find interviews transcripts of witnesses
SELECT name, transcript FROM interviews
WHERE month = 7 AND day = 28 AND year = 2023;

-- Select corresponding witnesses 
-- Selecting relevant witnesses
SELECT name, transcript FROM interviews
WHERE month = 7 AND day = 28 AND year = 2023 

-- Get witnesses transcript
AND name IN ('Ruth', 'Eugene', 'Raymond') 
AND transcript LIKE '%bakery%';

-- Witnesses are- Eugene, Raymond, and Ruth.

-- Ruth gave clues- The thief drove away in a car from the bakery, within 10 minutes from the theft. So, checking the license plates of cars within that timeframe. 
-- Then, checking out the names of those cars' owners. They could be suspect.

-- GET bakery security logs at 10:15am 
SELECT * FROM bakery_security_logs
WHERE
activity = 'exit'
AND month = 7 
AND day = 28 
AND year = 2023

-- Select expected timeframe (between 10:15am and 10:25am)
AND hour = 10 AND minute BETWEEN 15 AND 25;

-- We have the license_plate now I should check who is the owner. 

-- Select names of possible thief using people table
SELECT people.id, name, phone_number, passport_number, bakery.hour, bakery.minute
FROM people
JOIN bakery_security_logs AS bakery ON people.license_plate = bakery.license_plate
WHERE activity = 'exit'
AND month = 7 
AND day = 28 
AND year = 2023

-- Select expected timeframe (between 10:15am and 10:25am)
AND hour = 10
AND minute BETWEEN 15 AND 25

ORDER BY bakery.minute;

-- Create a temporary table for future analyze named possible_suspects

-- Create a temporary table of possible_suspects
CREATE TEMPORARY TABLE possible_suspects AS

-- Select names of possible thief using people table
SELECT people.id, name, phone_number, passport_number, bakery.hour, bakery.minute
FROM people
JOIN bakery_security_logs AS bakery ON people.license_plate = bakery.license_plate
WHERE activity = 'exit'
AND month = 7 
AND day = 28 
AND year = 2023

-- Select expected timeframe (between 10:15am and 10:25am)
AND hour = 10
AND minute BETWEEN 15 AND 25

ORDER BY bakery.minute;

-- Eugene gave clues the thief was withdrawing money from the ATM on Leggett Street. 

-- Find ATM withdraw the day of the stolen duck
SELECT * FROM atm_transactions
WHERE atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
AND month = 7 AND day = 28 AND year = 2023;

-- Create a temporary table for future analyze named suspects

-- Create a temporary table suspects
CREATE TEMPORARY TABLE suspects AS

-- Find the related name of suspects
SELECT * FROM possible_suspects
WHERE id IN (
    
    -- Select people ids 
    SELECT person_id FROM bank_accounts
    JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number
    
    -- Find ATM withdraw the day of the stolen duck
    WHERE atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
    AND month = 7 AND day = 28 AND year = 2023
);

-- Display suspects table
SELECT * FROM suspects;

-- Raymond gave clues
-- As leaving the bakery, they called a person and talked for less than a minute. 
-- They asked the person on the other end to purchase the flight ticket.

-- Check whom the thief called using the specified time frame and filter for calls with a duration of less than 1 minute.

-- Create a temporary table for future analyze named thief_suspects

-- Create a temporary table of thief_suspects
CREATE TEMPORARY TABLE thief_suspects AS

-- Create a temporary table of thief_suspects
CREATE TEMPORARY TABLE thief_suspects AS

-- Get the name of people who called
SELECT * FROM suspects
WHERE phone_number IN
(  
    -- The thief called someone for less than 1 min 
    SELECT caller FROM phone_calls
    WHERE month = 7 AND day = 28 AND year = 2023 AND duration <= 60
);

-- Dislay table
SELECT * FROM thief_suspects

-- The thief is one of this two 
-- Next, let's check who took the airplane on the 29 (the day after)


SELECT flights.hour, flights.minute, name, phone_number, thief_suspects.passport_number FROM passengers
JOIN thief_suspects ON passengers.passport_number = thief_suspects.passport_number
JOIN flights ON passengers.flight_id = flights.id
-- Select the corresponding day
WHERE year = 2023 
AND month = 7
AND day = 29
-- Order by departure time
ORDER BY flights.hour, flights.minute;

-- When the thief called he say that they were planning to take the earliest flight

-- Create a temporary table for future analyze named thief

-- Create a temporary table named thief
CREATE TEMPORARY TABLE thief AS

SELECT flight_id, origin_airport_id, destination_airport_id, 
flights.hour, flights.minute, 
name, phone_number, thief_suspects.passport_number 
FROM passengers
JOIN thief_suspects ON passengers.passport_number = thief_suspects.passport_number
JOIN flights ON passengers.flight_id = flights.id
-- Select the corresponding day
WHERE year = 2023 
AND month = 7
AND day = 29
-- Order by departure time
ORDER BY flights.hour, flights.minute
-- SELCT the earliest flight
LIMIT 1;

-- Show thief name
SELECT name FROM thief;

-- Get the city name where the thief went

-- Get the name of the name of the city where the thief went
SELECT city FROM airports
JOIN thief ON thief.destination_airport_id = airports.id;

-- Who is the accomplice ? 
-- Let's find who the thief asked the person on the other end of the phone to purchase the flight ticket.

-- Get the name of the accomplice
SELECT name FROM people
WHERE phone_number = (
    
    -- Get the phone number of the person whom the thief asked to purchase the flight ticket.
    SELECT receiver FROM phone_calls
    JOIN thief ON thief.phone_number = phone_calls.caller
    WHERE year = 2023
    AND month = 7
    AND day = 28
    AND duration <= 60
);

-- You can check all queries in my Jupyter Notebook link:
-- https://github.com/PiWebswiss/sql-log-SC50/blob/main/fiftyville/sql.ipynb