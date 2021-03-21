import * as functions from 'firebase-functions';
import * as express from 'express';
import * as cors from 'cors';
import * as admin from 'firebase-admin';
import {PushRequest} from './push-request';
import {PushMessage} from './push-message';
import {myIsNullOrUndefined} from './utils';
import {messaging} from 'firebase-admin/lib/messaging';
import MessagingOptions = messaging.MessagingOptions;

if (process.env.FUNCTIONS_EMULATOR === 'true') {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
} else {
  admin.initializeApp();
}


const app = express();
app.use(cors({origin: true}));


app.get('/hello', (req, res) => {
  res.send('Received GET request!');
});


app.post('/send', async (req, res) => {
  const pushRequest: PushRequest = req.body;

  if (myIsNullOrUndefined(pushRequest) || myIsNullOrUndefined(pushRequest.fcmId)) {
    return res.sendStatus(400);
  }

  const pushMessage = new PushMessage(pushRequest.content, new Date().toISOString(), pushRequest.host);

  const message = {
    notification: {
      title: `QR-code received from ${pushRequest.host}`,
      body: 'Click here to open',
    },
    data: pushMessage as any,
  };

  const messageOptions: MessagingOptions = {
    contentAvailable: true, // Wake up apple devices
    timeToLive: 30,
  };


  try {
    await admin.messaging().sendToDevice(pushRequest.fcmId, message, messageOptions);
    return res.sendStatus(200);
  } catch (e) {
    return res.sendStatus(500);
  }
});


export const widgets = functions.region('europe-west2').https.onRequest(app);

