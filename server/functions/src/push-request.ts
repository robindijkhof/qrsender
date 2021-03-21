/**
 * Class which represents a request to the server to send a push notifcation to the mobile device.
 */
export class PushRequest {
  content: string;
  host: string;
  fcmId: string;

  /**
   * @param content of the QR-code
   * @param host van de website waar de QR-code is gescanned
   * @param fcmId of the user to send the notification
   */
  constructor(content: string, host: string, fcmId: string) {
    this.content = content;
    this.fcmId = fcmId;
    this.host = host;
  }
}
