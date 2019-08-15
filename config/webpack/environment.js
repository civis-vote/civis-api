const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const webpack = require('webpack');
environment.plugins.append('Provide', new webpack.ProvidePlugin({
    $: require.resolve('jquery'),
    jQuery: require.resolve('jquery'),
    Popper: ['popper.js', 'default']
  })
)

const { add_paths_to_environment } = require(
  `${environment.plugins.get('Environment').defaultValues["PWD"]}/config/environments/_add_gem_paths`
)

add_paths_to_environment(environment)
const coffee =  require('./loaders/coffee')

environment.loaders.prepend('coffee', coffee)
environment.loaders.prepend('erb', erb)
module.exports = environment
