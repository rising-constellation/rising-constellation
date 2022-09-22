module.exports = {
  root: true,
  env: {
    node: true,
    browser: true,
  },
  extends: [
    'airbnb-base',
  ],
  rules: {
    'no-console': 'off',
    'no-debugger': 'warn',
    'prefer-template': 'off',
    'no-param-reassign': 'off',
    'no-nested-ternary': 'off',
    'template-curly-spacing': 'off',
    'max-len': ['error', { code: 150 }],
    'class-methods-use-this': 'warn',
    'no-underscore-dangle': 'off',
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
  },
  parserOptions: {
    parser: 'babel-eslint',
  },
};
