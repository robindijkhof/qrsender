export default class RequestMessage {
  content

  host

  fcmId

  /**
   * @param content of the QR-code
   * @param host van de website waar de QR-code is gescanned
   * @param fcmId of the user to send the notification
   */
  constructor(content, host, fcmId) {
    this.content = content
    this.fcmId = fcmId
    this.host = host
  }
}
