import React from 'react'
import ReactDOM from 'react-dom'
import {fcmId} from './isUrl'
import RequestMessage from './RequestMessage'
import {BrowserQRCodeReader} from '@zxing/browser'


class Scanner extends React.Component {
  constructor() {
    super()
    this.state = {
      text: 'Scanning for QR-code...',
    }

    chrome.tabs.captureVisibleTab(undefined, {format: 'jpeg'}, url => this.onCaptureVisibleTab(url))
  }

  onCaptureVisibleTab(dataUrl) {
    const codeReader = new BrowserQRCodeReader()
    codeReader.decodeFromImageUrl(dataUrl)
      .then((result) => {
        this.setState({text: 'QR-code found. Sending message to phone...'})
        return result.text
      })
      .then(result => this.sendPushMessage(result))
      .then(result => this.setState({text: result}))
      .catch((err) => {
        console.log(err) //eslint-disable-line
        this.setState({text: 'No QR code found or there are multiple QR codes!'})
      })
  }

  sendPushMessage(qrContent) {
    // console.log(': ', qrContent)
    const request = new RequestMessage(qrContent, 'myhost.com', fcmId)

    return fetch('http://localhost:5001/qrcode-receiver/europe-west2/widgets/send', {
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(request),
    })
      .then(() => 'Message send to phone')
      .catch(() => Promise.resolve('Could not send message to phone'))
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
