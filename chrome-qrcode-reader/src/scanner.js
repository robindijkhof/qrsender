import React from 'react'
import ReactDOM from 'react-dom'
import RequestMessage from './RequestMessage'
import {BrowserQRCodeReader} from '@zxing/browser'

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
    codeReader.decodeFromImageUrl(dataUrl)
      // Promise.resolve({text: 'qrcodewaarde'})
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

  getCurrentHost(){
    return new Promise((resolve => {
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        const tab = tabs[0]
        const url = new URL(tab.url)
        const host = url.hostname
        resolve(host)
      })
    }))


  }

  sendPushMessage(qrContent) {
    // Get the settings from storage
    return new Promise(resolve => chrome.storage.local.get(['settings'], resolve))
      // Throw exception if no registration token or else return it
      .then(({settings}) => {
        if(settings?.registrationToken && settings.registrationToken !== ''){
          return settings.registrationToken
        }else{
          throw 'No Registration Token configured'
        }
      })
      // Also get the current host
      .then(token => this.getCurrentHost().then(host => Promise.resolve([token, host])))
      // Make the request to the server to send the push notification
      .then(data => {
        const registrationToken = data[0]
        const host = data[1]
        const request = new RequestMessage(qrContent, host, registrationToken)

        // Make request with the registrationToken and the content
        // eslint-disable-next-line no-undef
        return fetch(process.env.SERVER_URL, {
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
            // From now on we don't care what the response is, as long as it isn't an error.
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
