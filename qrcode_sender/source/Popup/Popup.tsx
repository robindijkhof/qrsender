import {browser} from 'webextension-polyfill-ts';
import React from 'react';
import {BrowserQRCodeReader} from '@zxing/browser';
// import {BrowserQRCodeReader, Result} from "@zxing/library";
import {Result} from "@zxing/library";
import {RequestMessage} from '../models/request-message';
import {Settings} from "../models/settings";
import encrypt from "../utils/encryption-utils";

interface ScannerProps {
  text: string;
}

export class Popup extends React.Component<unknown, ScannerProps> {
  constructor(props: unknown) {
    super(props);
    this.state = {
      text: 'Scanning for QR-code...',
    };

    this.startScan();
  }

  async startScan(): Promise<void> {
    try {
      const qrcodeData = await this.getQrData();
      const requestMessage = await this.createRequestMessage(qrcodeData)
      await this.sendPushMessage(requestMessage);
      this.setState({text: 'Message send to phone'});
    } catch (err) {
      // TODO: verbeteren
      this.setState({text: err.message});
    }
  }

  async getQrData(): Promise<string> {
    const screenshotUrl = await browser.tabs.captureVisibleTab(undefined, {format: 'jpeg'});
    console.log(screenshotUrl);
    const codeReader = new BrowserQRCodeReader();
    let scannerResult: Result;
    try {
      scannerResult = await codeReader.decodeFromImageUrl(screenshotUrl);
      // scannerResult = await codeReader.decodeFromImage(undefined, screenshotUrl);
    } catch (e){
      console.log(e);
      throw new Error('No QR code found or there are multiple QR codes!');
    }
    this.setState({text: 'QR-code found. Sending message to phone...'});
    return scannerResult.getText();
  }

  async createRequestMessage(qrContent: string): Promise<RequestMessage>{
    const settings = (await browser.storage.local.get(['settings'])).settings as Settings;
    if(!settings || !settings.passphrase || settings.passphrase === ''){
      throw new Error('No encryption key configured');
    }
    if(!settings || !settings.registrationToken || settings.registrationToken === ''){
      throw new Error('No Registration Token configured');
    }

    const host = await this.getCurrentHost();
    const encryptedData = await encrypt(qrContent, settings.passphrase);
    return new RequestMessage(encryptedData, host, settings.registrationToken);
  }

  async getCurrentHost(): Promise<string> {
    const tab = (
      await browser.tabs.query({active: true, currentWindow: true})
    )[0];
    if(!tab.url){
      return '';
    }
    const url = new URL(tab.url);
    return url.hostname;
  }

  async sendPushMessage(requestMessage: RequestMessage): Promise<void> {
    let response;
    try{
      response = await fetch(
          process.env.SERVER_URL!.toString(),
          {
            method: 'post',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestMessage),
          });
    }catch (e){
      console.log(e)
      throw new Error('Error sending message to phone')
    }
    if (response.status >= 400 && response.status < 600) {
      return Promise.reject(new Error('Error send to phone'));
    }
    return Promise.resolve(undefined);
  }

  render(): React.ReactNode {
    const {text} = this.state;
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
    );
  }
}
