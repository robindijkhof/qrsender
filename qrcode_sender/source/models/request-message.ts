export class RequestMessage {
  content: string;

  host: string;

  registrationToken: string;

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

}
