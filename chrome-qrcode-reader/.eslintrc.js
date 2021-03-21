module.exports = {
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended"
  ],
  "plugins": [
    "react"
  ],
  "parser": "babel-eslint",
  "env": {
    "browser": true,
    "webextensions": true,
    "es6": true
  },
  "parserOptions": {
    "ecmaVersion": 7,
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "rules": {
    "react/jsx-filename-extension": "off",
    "semi": ["error", "never"],
    "react/prop-types": "off",
    "jsx-a11y/alt-text": "off"
  }
};
