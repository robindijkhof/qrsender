import React from 'react'
import ReactDOM from 'react-dom'


class Settings extends React.Component {
  constructor(props) {
    super(props)

    // Init state
    this.state = {
      registrationToken: '',
      passphrase: '',
    }

    // Update state from storage
    chrome.storage.local.get(['settings'], (result) => this.setState(result.settings))
  }

  formChangeHandler = (event) => {
    // Get the key and the value of the field that changed
    const key = event.target.name
    const value = event.target.value

    // Update the current state
    this.setState({
      ...this.state,
      [key]: value
    })
  }

  saveForm() {
    const formValue = this.state
    chrome.storage.local.set({settings: formValue}, () => alert('saved!'))
  }

  render() {
    const {registrationToken} = this.state
    const {passphrase} = this.state

    return (
      <div style={{width: 400, margin: 'auto'}}>
        <h1>Settings</h1>
        <form>
          <div style={{display: 'grid'}}>
            <label htmlFor="registrationToken">FCM ID</label>
            <textarea style={{marginBottom: 12, resize: 'vertical'}} name="registrationToken" onChange={this.formChangeHandler} value={registrationToken}/>
            <label htmlFor="passphrase">Passphrase</label>
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
