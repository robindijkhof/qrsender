/**
 * Class which represents the data of a pushmessage sent to the device
 */
export class PushMessage {
  content: string;
  datetime: string;
  host: string;

  /**
   *
   * @param content of the QR-code
   * @param datetime moment van scanner
   * @param host van de website waar de QR-code is gescanned
   */
  constructor(content: string, datetime: string, host: string) {
    this.content = content;
    this.datetime = datetime;
    this.host = host;
  }
}
