#Server
This project is used to expose an API to send a puh message to the QR app.

##Instruction
Create a firebase project and add the location of the private key to your environment.

`export GOOGLE_APPLICATION_CREDENTIALS="/home/user/Downloads/service-account-file.json"`

Install and run

```
npn install
npm serve
```

##Request example

```
{
  'host': 'myhost.com',
  'content': 'QRCODE_CONTENT',
  'registrationToken': 'MY_DEVICE_ID'
}
```

