This project was created using https://github.com/abhijithvijayan/web-extension-starter

## 🚀 Quick Start

Ensure you have

- [Node.js](https://nodejs.org) 10 or later installed

Then run the following:

- `npm install` to install dependencies.
- `npm run dev:chrome` to start the development server for chrome extension
- `npm run dev:firefox` to start the development server for firefox addon
- `npm run dev:opera` to start the development server for opera extension
- `npm run build:chrome` to build chrome extension
- `npm run build:firefox` to build firefox addon
- `npm run build:opera` to build opera extension
- `npm run build` builds and packs extensions all at once to extension/ directory

### Development

- `yarn install` to install dependencies.
- To watch file changes in development

  - Chrome
    - `yarn run dev:chrome`
  - Firefox
    - `yarn run dev:firefox`
  - Opera
    - `yarn run dev:opera`

- **Load extension in browser**

- ### Chrome

  - Go to the browser address bar and type `chrome://extensions`
  - Check the `Developer Mode` button to enable it.
  - Click on the `Load Unpacked Extension…` button.
  - Select your extension’s extracted directory.

- ### Firefox

  - Load the Add-on via `about:debugging` as temporary Add-on.
  - Choose the `manifest.json` file in the extracted directory

- ### Opera

  - Load the extension via `opera:extensions`
  - Check the `Developer Mode` and load as unpacked from extension’s extracted directory.

### Production

- `npm run build` builds the extension for all the browsers to `extension/BROWSER` directory respectively.


## License

MIT © [Abhijith Vijayan](https://abhijithvijayan.in)
