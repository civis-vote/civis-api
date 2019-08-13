const { environment } = require('@rails/webpacker')
const webpack = require('webpack');
environment.plugins.append('Provide',
  new webpack.ProvidePlugin({
    $: require.resolve('jquery'),
    jQuery: require.resolve('jquery')
  })
)
const { add_paths_to_environment } = require(
  `${environment.plugins.get('Environment').defaultValues["PWD"]}/config/environments/_add_gem_paths`
)

add_paths_to_environment(environment)
module.exports = environment
