

export const fcmId = 'xPGZPKzSyuI2L-Sm_wC0F:APA91bGfClMeO80cbcXlK0fiHCZyEq91n_OEuX0B4sZeHbuSdyMEIlNNahtKiAeB_e-CbKAKxfsl-hlp6SfG37fb3vsK1os8-gUxMONowUnHr8RbQhfFce35VXsXXZyHdOX1_uzqdsOV';

// https://github.com/segmentio/is-url/blob/master/index.js

/**
 * RegExps.
 * A URL must match #1 and then at least one of #2/#3.
 * Use two levels of REs to avoid REDOS.
 */

const protocolAndDomainRE = /^(?:\w+:)?\/\/(\S+)$/

const localhostDomainRE = /^localhost[\:?\d]*(?:[^\:?\d]\S*)?$/ // eslint-disable-line
const nonLocalhostDomainRE = /^[^\s\.]+\.\S{2,}$/ //eslint-disable-line

/**
 * Loosely validate a URL `string`.
 *
 * @param {String} string
 * @return {Boolean}
 */

export default function isUrl(string) {
  if (typeof string !== 'string') {
    return false
  }

  const match = string.match(protocolAndDomainRE)
  if (!match) {
    return false
  }

  const everythingAfterProtocol = match[1]
  if (!everythingAfterProtocol) {
    return false
  }

  if (localhostDomainRE.test(everythingAfterProtocol)
    || nonLocalhostDomainRE.test(everythingAfterProtocol)) {
    return true
  }

  return false
}
