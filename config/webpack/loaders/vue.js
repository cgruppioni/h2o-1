const { dev_server: devServer } = require('@rails/webpacker').config;

const isProduction = process.env.NODE_ENV === 'production';
const inDevServer = process.argv.find(v => v.includes('webpack-dev-server'));
const extractCSS = !(inDevServer && (devServer && devServer.hmr)) || isProduction;

module.exports = {
  test: /\.vue(\.erb)?$/,
  use: [{
    loader: 'vue-loader',
    options: {extractCSS,
              // Enabled to prevent annotations from incurring incorrect
              // offsets due to extra whitespace in templates
              // TODO - the next Vue release introduces an even more useful
              // type of whitespace trimming: https://github.com/vuejs/vue/issues/9208#issuecomment-450012518
              preserveWhitespace: false}
  }]
};
