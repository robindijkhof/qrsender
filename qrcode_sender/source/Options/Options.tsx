import React from 'react';
import {browser} from 'webextension-polyfill-ts';

interface OptionsState {
  registrationToken: string;
  passphrase: string;
}

export class Options extends React.Component<unknown, OptionsState> {
  constructor(props: unknown) {
    super(props);

    // Init state
    this.state = {
      registrationToken: '',
      passphrase: '',
    };

    // Update state from storage
    browser.storage.local
      .get(['settings'])
      .then((result) => this.setState(result.settings));
  }

  formChangeHandler = (
    event:
      | React.ChangeEvent<HTMLInputElement>
      | React.ChangeEvent<HTMLTextAreaElement>
  ) => {
    // Get the key and the value of the field that changed
    const key = event.target.name;
    const {value} = event.target;

    // Update the current state
    this.setState({
      ...this.state,
      [key]: value,
    });
  };

  saveForm(_: React.MouseEvent<HTMLButtonElement>): void {
    const formValue = this.state;
    browser.storage.local
      .set({settings: formValue})
      // eslint-disable-next-line no-alert
      .then(() => alert('saved!'));

    navigator.credentials.get()
  }

  render(): React.ReactNode {
    const {registrationToken} = this.state;
    const {passphrase} = this.state;

    return (
      <div style={{width: 400, margin: 'auto'}}>
        <h1>Settings</h1>
        <form>
          <div style={{display: 'grid'}}>
            <label htmlFor="registrationToken">FCM ID</label>
            <textarea
              style={{marginBottom: 12, resize: 'vertical'}}
              name="registrationToken"
              onChange={this.formChangeHandler}
              value={registrationToken}
            />
            <label htmlFor="passphrase">Encryption key</label>
            <input
              style={{marginBottom: 12}}
              type="text"
              name="passphrase"
              onChange={this.formChangeHandler}
              value={passphrase}
            />
          </div>
          <button type="button" onClick={(e) => this.saveForm(e)}>
            Save
          </button>
        </form>
      </div>
    );
  }
}
