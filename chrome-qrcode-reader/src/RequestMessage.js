export default class RequestMessage {
  content

  host

  registrationToken

  /**
   * @param content of the QR-code
   * @param host van de website waar de QR-code is gescanned
   * @param registrationToken of the user to send the notification
   */
  constructor(content, host, registrationToken) {
    this.content = content
    this.registrationToken = registrationToken
    this.host = host
  }
}
