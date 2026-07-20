import csv
import firebase_admin
from firebase_admin import db, auth, credentials
import requests

SERVICE_ACCOUNT_KEY_PATH = 'C:/mate_flutter/tiszapp-175fb-firebase-adminsdk-wj70k-980a6ad90e.json'
USERS_CSV_PATH = 'C:/mate_flutter/test.csv'
PROFILE_PICTURE_URL = 'https://firebasestorage.googleapis.com/v0/b/tiszapp-175fb.appspot.com/o/profile_pictures%2Fdefault.jpg?alt=media&token=51830fc5-17d3-46f1-9ddf-3265656dea48'

SEND_EMAILS = True
EMAIL_API_URL = 'https://mail.kir-dev.hu/api/send'
EMAIL_API_KEY_PATH = "C:/mate_flutter/email-api-key.txt"

def sanitize(name):
    return name.lower().replace(' ', '')

def registrateUser(name, pin, team):
    global successful_registrations
    if name == '' or name is None:
        print('Invalid name, skipping user creation.')
        return
    if team == '' or team is None:
        team = -1
    try:
        user = auth.create_user(
            email = sanitize(name) + "@tiszap.hu",
            #display_name = name,
            password = pin
        )
        uid = user.uid
        print(f"[1/2] {name} (UID: {uid})  Created Auth user")

        user_ref = ref.child(uid)
        user_ref.set({
            'uid': uid,
            'userName': name,
            'admin': team == 0,
             #as integer
            'groupNumber': int(team),
            'profilePictureUrl': PROFILE_PICTURE_URL,
        })
        print(f"[2/2] {name} (UID: {uid})  Data saved for user")
        successful_registrations += 1

    except Exception as e:
        print(f'Error creating {name} :', e)
        return


def sendEmail(name, pin, email):
    emailData = getEmailText(name, email, pin)
    headers = {
        'Authorization': f'Api-Key {EMAIL_API_KEY}',
        'Content-Type': 'application/json'
    }
    try:
        response = requests.post(EMAIL_API_URL, json=emailData, headers=headers)
        response.raise_for_status()
        print(f"[ +1] {name}  Email sent successfully")

    except requests.exceptions.RequestException as e:
        print(f"Failed to send email: {e}")
    return


def getEmailText(name, email, code):
    return {
        "from": {
            "name": "TiszaP szervezők",
            "email": "noreply@tiszap.hu"
        },
        "to": email,
        "subject": f"TiszApp letöltés",
        "html": (
            f"<h2>Kedves {name}!</h2>"
            f"<p>Már nem kell sokat aludni a táborig, reméljük, hogy Te is legalább olyan izgatott vagy, mint Mi :) ! </p>"
            f"<p>Ebben az évben is lesz tábori mobilkalmazás, a TiszApp, ami bár egyáltalán nem kötelező része a táborozásnak, "
            f" de egy kicsit tovább emeli annak élményét, ezért ajánljuk letöltését. "
            f"Az alkalmazást letöltheted iOS-re az Apple Store-ból, illetve Android-ra a weboldalunkról:</p>"
            f"<b><a href=\"https://apps.apple.com/fi/app/tiszapp/id6451455483\">Letöltés iOS-re az Apple Store-ból</a></b><br>"
            f"<b><a href=\"https://www.tiszapp.kir-dev.hu\">Letöltés Androidra a weboldalunkról</a></b><br>"
            f"<p>A letöltés után (idéntől) egyből bejelentkezheztsz a neved kiválasztásával és a titkos 6 jegyű kódod beírásával. Szerintünk minden egyértelmű lesz!</p>"
            f"<p>A titkos személyes kódod: <h2>{code}</h2></p>"
            f"<p></p>"
            f"<p>Örülünk, hogy idén velünk táborozol majd TiszaPén! Ott tali!<br>A Szervezők</p>"
            f"<br><br><br><br>"
            f"<p><i>Az email küldést a Kir-Dev biztosította nekünk. Ez egy automatikus email, kérünk ne válaszolj rá!</i></p>"
        ),
        "replyTo": "mozsarmatee@gmail.com",
        "queue": "send"
    }



#/////////////////////////////////////////////////////////////////////////////////
cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tiszapp-175fb-default-rtdb.europe-west1.firebasedatabase.app/'
})
ref = db.reference('users')
email_auth_key_file = open(EMAIL_API_KEY_PATH, 'r')
EMAIL_API_KEY = email_auth_key_file.read().strip()

users = []
successful_registrations = 0
with open(USERS_CSV_PATH, mode='r', encoding='utf-8') as file:
    reader = csv.DictReader(file)

    for row in reader:
        name  = row['name']
        team  = row['team']
        pin   = row['pin']
        email = row['email']
        users.append({
            'name': name,
            'team': team,
            'pin': pin,
            'email': email
        })


for record in users:
    registrateUser(record['name'], record['pin'], record['team'])

    if SEND_EMAILS:
        sendEmail(record['name'], record['pin'], record['email'])

print(f"Batch registration completed. {successful_registrations} users registered successfully out of {len(users)}.")
