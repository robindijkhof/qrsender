export default class RequestMessage {
  content

  host

  registrationToken

  data

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

  getMessageData(){
    return new MessageData(this.content, this.host)
  }
}

export class MessageData{
  content

  host

  /**
   * @param content of the QR-code
   * @param host van de website waar de QR-code is gescanned
   */
  constructor(content, host) {
    this.content = content
    this.host = host
  }
}
