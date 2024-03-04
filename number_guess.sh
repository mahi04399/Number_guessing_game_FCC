#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align -t -c"

# take username as input
echo "Enter your username:"
read USERNAME
USERNAME_CHECK_RESULT=$($PSQL "SELECT * FROM USERS WHERE USERNAME='$USERNAME';")

if [[ -z $USERNAME_CHECK_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_INSERT_RESULT=$($PSQL "INSERT INTO USERS(USERNAME) VALUES('$USERNAME');")
fi

USER_ID=$($PSQL "SELECT USER_ID FROM USERS WHERE USERNAME='$USERNAME';");
GAME_RETRIEVAL_RESULT=$($PSQL "SELECT GAMES_PLAYED, BEST_GAME FROM GAMES WHERE USER_ID=$USER_ID;");
if [[ -z $GAME_RETRIEVAL_RESULT ]]
then
  GAME_INSERT_RESULT=$($PSQL "INSERT INTO GAMES(USER_ID, GAMES_PLAYED, BEST_GAME) VALUES($USER_ID, 0, 1001);")
  GAMES_PLAYED=0;
  BEST_GAME=1001;
else
  # IFS='|'
  # read GAMES_PLAYED BEST_GAME <<< $GAME_RETRIEVAL_RESULT
  # unset IFS

  GAMES_PLAYED=$($PSQL "SELECT GAMES_PLAYED FROM GAMES WHERE USER_ID=$USER_ID;");
  BEST_GAME=$($PSQL "SELECT BEST_GAME FROM GAMES WHERE USER_ID=$USER_ID;");
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((1 + RANDOM % 1000))
# SECRET_NUMBER=10
GUESS=-1
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

# till guess is not right
until [[ $GUESS -eq $SECRET_NUMBER ]]
do
 # take guess
 # guess_count++
 read GUESS
 GUESS_COUNT=$((GUESS_COUNT + 1))

 if [[ ! $GUESS =~ ^[0-9]+$ ]]
 then
  echo "That is not an integer, guess again:"
 else
  if [[ $GUESS -lt $SECRET_NUMBER ]] 
  then
   echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
   echo "It's lower than that, guess again:"
  fi
 fi
done

# print game stats
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

# update game stats for user
if [[ $GUESS_COUNT -lt $BEST_GAME ]]
then
  GAME_UPDATE_RESULT=$($PSQL "UPDATE GAMES SET GAMES_PLAYED=GAMES_PLAYED+1, BEST_GAME=$GUESS_COUNT WHERE USER_ID=$USER_ID;")
else
  GAME_UPDATE_RESULT=$($PSQL "UPDATE GAMES SET GAMES_PLAYED=GAMES_PLAYED+1 WHERE USER_ID=$USER_ID;")
fi

# flow charts
#           - - - - - - -  --gt
#          /                /
# read guess + incremetn ->    
#         \                 \
#          - - - - - - - - - lt



# if              user exist                  game deatils present -> get game     
#                    ||                     /                           ||
#                    ||===========>>> userid                            ||===========>>>>> play and update game
#                    ||                      \                          ||
# does not exist->insert user                  game details absent -> insert new game


# Thanks!
