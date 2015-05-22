module.exports = {
  entry: "./web/static/entry.js",
  output: {
    path: "./priv/static/js",
    filename: "bundle.js"
  },
  resolve: {
    root: [
      __dirname + "/web/static/js",
      __dirname + "/web/static/vendor"
    ],
    alias: {
      react$: "react/addons"
    }
  },
  module: {
    loaders: [
    {
     test: /\.scss$/,
     loader: "style!css!sass"
    },
    {
     test: /\.sass$/,
     loader: "style!css!sass?indentedSyntax"
    },
    {
      test: /\.js$/,
      exclude: /node_modules/,
      loader: "babel-loader"
    }
    ]
  }
};