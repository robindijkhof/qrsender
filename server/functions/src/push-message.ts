/**
 * Class which represents the data of a pushmessage sent to the device
 */
export class PushMessage {
  content: string;
  datetime: string;
  host: string;
  data: string;

  /**
   *
   * @param {string} content of the QR-code
   * @param {string} datetime moment van scanner
   * @param {string} host van de website waar de QR-code is gescanned
   * @param {string} data encrypted data
   */
  constructor(content: string, datetime: string, host: string, data: string) {
    this.content = content;
    this.datetime = datetime;
    this.host = host;
    this.data = data;
  }
}
