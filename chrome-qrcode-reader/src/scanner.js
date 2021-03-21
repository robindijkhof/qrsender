import React from 'react'
import ReactDOM from 'react-dom'
import RequestMessage from './RequestMessage'
import {BrowserQRCodeReader} from '@zxing/library'


class Scanner extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      text: 'Scanning for QR-code...',
    }

    chrome.tabs.captureVisibleTab(undefined, {format: 'jpeg'}, url => this.onCaptureVisibleTab(url))

    // chrome.storage.local.get(['settings'], (result) => this.setState({test: JSON.stringify(result.settings)}))
  }

  onCaptureVisibleTab(dataUrl) {
    const codeReader = new BrowserQRCodeReader()
    // codeReader.decodeFromImage(undefined, dataUrl)
      Promise.resolve({text: 'qrcodewaarde'})
      .catch(() => Promise.reject('No QR code found or there are multiple QR codes!'))
      .then((result) => {
        this.setState({text: 'QR-code found. Sending message to phone...'})
        return result.text
      })
      .then(result => this.sendPushMessage(result))
      .then(() => this.setState({text: 'Message send to phone'}))
      .catch((err) => {
        if (typeof err === 'string') {
          this.setState({text: err})
        } else {
          this.setState({text: 'Unknown error'})
        }
      })
  }

  sendPushMessage(qrContent) {
    // Get the settings from storage
    return new Promise(resolve => chrome.storage.local.get(['settings'], resolve))
      // Throw exception if no fcmId or else return it
      .then(({settings}) => {
        if(settings?.fcmId && settings.fcmId !== ''){
          return settings.fcmId
        }else{
          throw 'No FCM ID configured'
        }
      })
      // Make the request to the server to send the push notification
      .then(fcmId => {
        const request = new RequestMessage(qrContent, 'myhost.com', fcmId)

        // Make request qith the fcmId and the content
        return fetch('http://localhost:5001/qrcode-receiver/europe-west2/widgets/send', {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(request),
        })
          // Handle 400 to 600 as errors.
          .then(response => {
            if (response.status >= 400 && response.status < 600) {
              return Promise.reject('Error send to phone')
            }
            return ''
          })
          // Handle other request errors
          .catch(() => Promise.reject('Error send to phone'))
      })
  }

  render() {
    const {text} = this.state
    return (
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-around',
          alignItems: 'center',
          marginTop: 30,
        }}
      >
        <p>{text}</p>
      </div>
    )
  }
}

ReactDOM.render(
  <Scanner/>,
  document.getElementById('scanner'),
)
