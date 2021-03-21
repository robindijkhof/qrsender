import React from 'react'
import ReactDOM from 'react-dom'


class Settings extends React.Component {
  constructor() {
    super()
    this.state = {
      fcmId: 'hah',
      passphrase: 'asd',
    }
  }

  formChangeHandler = (event) => {
    const fcmId = event.target.fcmId
    const passphrase = event.target.passphrase
    this.setState({
      fcmId,
      passphrase,
    })
  }

  saveForm() {
    const formValue = this.state
    chrome.storage.local.set({settings: formValue}, function () {
      alert('saved!')
    })
    console.log('save', formValue)
  }

  render() {
    const {fcmId} = this.state
    const {passphrase} = this.state

    return (
      <div style={{width: 400, margin: 'auto'}}>
        <h1>Settings</h1>
        <form>
          <div style={{display: 'grid'}}>
            <label htmlFor="fcmId">FCM ID</label>
            <textarea style={{marginBottom: 12, resize: 'vertical'}} name="fcmId" onChange={this.formChangeHandler} value={fcmId}/>
            <label htmlFor="fcmId">Passphrase</label>
            <input style={{marginBottom: 12}} type="text" name="passphrase" onChange={this.formChangeHandler} value={passphrase}/>
          </div>
          <button type="button" onClick={() => this.saveForm()}>Save</button>
        </form>
      </div>
    )
  }
}

ReactDOM.render(
  <Settings/>,
  document.getElementById('settings'),
)
