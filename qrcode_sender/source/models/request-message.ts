import {MessageData} from './message-data';

export class RequestMessage {
  content: string;

  host: string;

  registrationToken: string;

  data: string;

  /**
   * @param content of the QR-code
   * @param host van de website waar de QR-code is gescanned
   * @param registrationToken of the user to send the notification
   */
  constructor(content: string, host: string, registrationToken: string) {
    this.content = content;
    this.registrationToken = registrationToken;
    this.host = host;
  }

  getMessageData(): MessageData {
    return new MessageData(this.content, this.host);
  }
}
