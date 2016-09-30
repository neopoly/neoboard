var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin")

var vendors = [
  "react",
  "lodash",
  "classnames",
  "react-intl",
  "react-grid-layout",
  "phoenix",
  "emojify"
];

module.exports = {
  entry: {
    application: "./web/static/entry.js",
    vendors: vendors
  },
  devtool: "source-map",
  output: {
    path: "./priv/static/js",
    filename: "[name].js"
  },
  resolve: {
    root: [
      __dirname + "/web/static/js",
      __dirname + "/web/static/vendor"
    ]
  },
  plugins: [
    new CommonsChunkPlugin("vendors", "vendors.js")
  ],
  module: {
    noParse: vendors,
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
