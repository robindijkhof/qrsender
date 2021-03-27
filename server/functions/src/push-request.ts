/**
 * Class which represents a request to the server to send a push notifcation to the mobile device.
 */
export class PushRequest {
  content: string;
  host: string;
  registrationToken: string;

  /**
   * @param {string} content of the QR-code
   * @param {string} host van de website waar de QR-code is gescanned
   * @param {string} registrationToken of the user to send the notification
   */
  constructor(content: string, host: string, registrationToken: string) {
    this.content = content;
    this.registrationToken = registrationToken;
    this.host = host;
  }
}
