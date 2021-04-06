export class MessageData {
  content: string;

  host: string;

  /**
   * @param content of the QR-code
   * @param host van de website waar de QR-code is gescanned
   */
  constructor(content: string, host: string) {
    this.content = content;
    this.host = host;
  }
}
