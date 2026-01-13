import csv
import firebase_admin
from firebase_admin import db, auth, credentials

SERVICE_ACCOUNT_KEY_PATH = 'C:/mate_flutter/tiszapp-175fb-firebase-adminsdk-wj70k-980a6ad90e.json'
USERS_CSV_PATH = 'C:/mate_flutter/test.csv'
SEND_EMAILS = False
PROFILE_PICTURE_URL = 'https://firebasestorage.googleapis.com/v0/b/tiszapp-175fb.appspot.com/o/profile_pictures%2Fdefault.jpg?alt=media&token=51830fc5-17d3-46f1-9ddf-3265656dea48'
EMAIL_API_URL = 'https://your-email-api-endpoint.com/send'
EMAIL_TEMPLATE = 'C:/mate_flutter/helpers/emailTemplate.html'

def sanitize(name):
    return name.lower().replace(' ', '')

def registrateUser(name, pin, team):
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
        print('Error creating {name} :', e)
        return


def sendEmail(name, pin):
    pass



cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tiszapp-175fb-default-rtdb.europe-west1.firebasedatabase.app/'
})
ref = db.reference('users')

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
        sendEmail()
        print(counter, ". email sent")

print(f"Batch registration completed. {successful_registrations} users registered successfully out of {len(users)}.")
