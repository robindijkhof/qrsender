async function getKeyMaterial(passphrase: string): Promise<CryptoKey>{
  const enc = new TextEncoder()
  return crypto.subtle.importKey(
    'raw',
    enc.encode(passphrase),
    'PBKDF2',
    false,
    ['deriveBits', 'deriveKey']
  )
}

export default async function encrypt(value: string, passphrase: string): Promise<string> {
  const salt = window.crypto.getRandomValues(new Uint8Array(16))
  const iv = window.crypto.getRandomValues(new Uint8Array(12))

  const keyMaterial = await getKeyMaterial(passphrase)
  const key = await window.crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt,
      iterations: 100000,
      hash: 'SHA-256'
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256},
    true,
    [ 'encrypt', 'decrypt' ]
  )

  const encoder = new TextEncoder()
  const encrypted = await window.crypto.subtle.encrypt(
    {
      name: 'AES-GCM',
      iv
    },
    key,
    encoder.encode(value)
  )

  const encryptedArray = new Uint8Array(encrypted);

  const mergedArray = new Uint8Array(salt.length + iv.length + encryptedArray.length)
  mergedArray.set(salt)
  mergedArray.set(iv, salt.length)
  mergedArray.set(encryptedArray, iv.length + salt.length)

  let binary = '';
  for (let i = 0; i < mergedArray.length; i++) {
    binary += String.fromCharCode(mergedArray[i]);
  }
  return btoa(binary);

  // return btoa(String.fromCharCode(...mergedArray))
}


