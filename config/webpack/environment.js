const { environment } = require('@rails/webpacker')

// This exposes the global dependencies expected by Bootstrap's JS
// see https://gist.github.com/yalab/cad361056bae02a5f45d1ace7f1d86ef
const webpack = require('webpack')
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    JQuery: 'jquery',
    jquery: 'jquery',
    jQuery: 'jquery',
}))

module.exports = environment
